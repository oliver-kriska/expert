defmodule Expert do
  use GenLSP
  require Logger
  require Expert.Runtime

  alias Expert.Runtime

  def start_link(args) do
    {args, opts} =
      Keyword.split(args, [
        :dynamic_supervisor
      ])

    GenLSP.start_link(__MODULE__, args, opts)
  end

  @impl true
  def init(lsp, args) do
    dynamic_supervisor = Keyword.fetch!(args, :dynamic_supervisor)

    {:ok,
     assign(lsp,
       dynamic_supervisor: dynamic_supervisor,
       exit_code: 1,
       client_capabilities: nil
     )}
  end

  @impl true
  def handle_request(
        %GenLSP.Requests.Initialize{
          params: %GenLSP.Structures.InitializeParams{
            root_uri: root_uri,
            workspace_folders: workspace_folders,
            capabilities: caps
          }
        },
        lsp
      ) do
    parent = self()
    name = Path.basename(root_uri)

    working_dir = URI.parse(root_uri).path

    DynamicSupervisor.start_child(
      lsp.assigns.dynamic_supervisor,
      {Expert.Runtime.Supervisor,
       path: Path.join(working_dir, ".expert-lsp"),
       name: name,
       lsp: lsp,
       lsp_pid: parent,
       runtime: [
         working_dir: working_dir,
         uri: root_uri,
         on_initialized: fn status ->
           if status == :ready do
             msg = {:runtime_ready, name, self()}

             Process.send(parent, msg, [])
           else
             send(parent, {:runtime_failed, name, status})
           end
         end
       ]}
    )

    {:reply,
     %GenLSP.Structures.InitializeResult{
       capabilities: %GenLSP.Structures.ServerCapabilities{
         text_document_sync: %GenLSP.Structures.TextDocumentSyncOptions{
           open_close: true,
           save: %GenLSP.Structures.SaveOptions{include_text: true},
           change: GenLSP.Enumerations.TextDocumentSyncKind.incremental()
         },
         document_symbol_provider: true,
         workspace: %{
           workspace_folders: %GenLSP.Structures.WorkspaceFoldersServerCapabilities{
             supported: true,
             change_notifications: true
           }
         }
       },
       server_info: %{name: "Expert"}
     },
     assign(lsp,
       root_uri: root_uri,
       workspace_folders: workspace_folders,
       client_capabilities: caps
     )}
  end

  def handle_request(
        %GenLSP.Requests.TextDocumentDocumentSymbol{params: %{text_document: %{uri: uri}}},
        lsp
      ) do
    path = URI.parse(uri).path
    doc = File.read!(path)

    lsp =
      if lsp.assigns[:runtime] == nil do
        receive do
          {:runtime_ready, _name, runtime_pid} = msg ->
            send(self(), msg)
            assign(lsp, ready: true, runtime: runtime_pid)
        end
      else
        lsp
      end

    symbols =
      Expert.Runtime.execute! lsp.assigns.runtime do
        Engine.DocumentSymbol.fetch(doc)
      end

    # which then will get serialized again on the way out
    # we could potentially namespace our app too, but i think that
    # makes our dev experience worse

    {:reply, symbols, lsp}
  end

  def handle_request(%GenLSP.Requests.Shutdown{}, lsp) do
    {:reply, nil, assign(lsp, exit_code: 0)}
  end

  def handle_request(request, lsp) do
    {:reply,
     %GenLSP.ErrorResponse{
       code: GenLSP.Enumerations.ErrorCodes.method_not_found(),
       message: "Method Not Found: #{request.method}"
     }, lsp}
  end

  @impl true
  def handle_notification(%GenLSP.Notifications.Initialized{}, lsp) do
    Logger.info("Expert v#{version()} has initialized!")

    Logger.info("Log file located at #{Path.join(File.cwd!(), ".expert-lsp/expert.log")}")

    {:noreply, lsp}
  end

  def handle_notification(_notification, lsp) do
    {:noreply, lsp}
  end

  def handle_info({:runtime_ready, _name, runtime_pid}, lsp) do
    GenLSP.log(lsp, "[Expert] Runtime is ready")
    Runtime.compile(runtime_pid)

    {:noreply, assign(lsp, ready: true, runtime: runtime_pid)}
  end

  def handle_info({:compiler_result, _name, result}, lsp) do
    case result do
      {status, diagnostics} when status not in [:ok, :noop] ->
        per_file =
          for d <- diagnostics, reduce: Map.new() do
            acc ->
              diagnostic = %GenLSP.Structures.Diagnostic{
                severity: severity(d.severity),
                message: IO.iodata_to_binary(d.message),
                source: d.compiler_name,
                range: range(d.position, Map.get(d, :span))
              }

              Map.update(acc, d.file, [diagnostic], &[diagnostic | &1])
          end

        for {file, diagnostics} <- per_file do
          GenLSP.notify(lsp, %GenLSP.Notifications.TextDocumentPublishDiagnostics{
            params: %GenLSP.Structures.PublishDiagnosticsParams{
              uri: "file://#{file}",
              diagnostics: diagnostics
            }
          })
        end

      _ ->
        nil
    end

    {:noreply, lsp}
  end

  def version do
    case :application.get_key(:expert, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> "dev"
    end
  end

  defp severity(:error), do: GenLSP.Enumerations.DiagnosticSeverity.error()
  defp severity(:warning), do: GenLSP.Enumerations.DiagnosticSeverity.warning()
  defp severity(:info), do: GenLSP.Enumerations.DiagnosticSeverity.information()
  defp severity(:hint), do: GenLSP.Enumerations.DiagnosticSeverity.hint()

  defp range({start_line, start_col, end_line, end_col}, _) do
    %GenLSP.Structures.Range{
      start: %GenLSP.Structures.Position{
        line: clamp(start_line - 1),
        character: start_col - 1
      },
      end: %GenLSP.Structures.Position{
        line: clamp(end_line - 1),
        character: end_col - 1
      }
    }
  end

  defp range({startl, startc}, {endl, endc}) do
    %GenLSP.Structures.Range{
      start: %GenLSP.Structures.Position{
        line: clamp(startl - 1),
        character: startc - 1
      },
      end: %GenLSP.Structures.Position{
        line: clamp(endl - 1),
        character: endc - 1
      }
    }
  end

  defp range({line, col}, nil) do
    %GenLSP.Structures.Range{
      start: %GenLSP.Structures.Position{
        line: clamp(line - 1),
        character: col - 1
      },
      end: %GenLSP.Structures.Position{
        line: clamp(line - 1),
        character: 999
      }
    }
  end

  defp range(line, _) do
    %GenLSP.Structures.Range{
      start: %GenLSP.Structures.Position{
        line: clamp(line - 1),
        character: 0
      },
      end: %GenLSP.Structures.Position{
        line: clamp(line - 1),
        character: 999
      }
    }
  end

  def clamp(line), do: max(line, 0)
end
