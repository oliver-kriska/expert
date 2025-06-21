defmodule Expert.State do
  alias Engine.Api
  alias Expert.CodeIntelligence
  alias Expert.Configuration
  alias Expert.Project
  alias Expert.Provider.Handlers
  alias Expert.Transport
  alias Forge.Document
  alias Forge.Project
  alias Forge.Protocol.Id
  alias Forge.Protocol.Response
  alias GenLSP.Enumerations
  alias GenLSP.Notifications
  alias GenLSP.Requests
  alias GenLSP.Structures

  require Logger

  import Api.Messages

  defstruct configuration: nil,
            initialized?: false,
            shutdown_received?: false,
            in_flight_requests: %{}

  @supported_code_actions [
    Enumerations.CodeActionKind.quick_fix(),
    Enumerations.CodeActionKind.refactor(),
    Enumerations.CodeActionKind.refactor_extract(),
    Enumerations.CodeActionKind.refactor_inline(),
    Enumerations.CodeActionKind.refactor_rewrite(),
    Enumerations.CodeActionKind.source(),
    Enumerations.CodeActionKind.source_fix_all(),
    Enumerations.CodeActionKind.source_organize_imports()
  ]

  def new do
    %__MODULE__{}
  end

  def initialize(%__MODULE__{initialized?: false} = state, %Requests.Initialize{
        id: event_id,
        params: %Structures.InitializeParams{} = event
      }) do
    client_name =
      case event.client_info do
        %{name: name} -> name
        _ -> nil
      end

    root_path = Forge.Document.Path.from_uri(event.root_uri)

    root_path
    |> Forge.Workspace.new()
    |> Forge.Workspace.set_workspace()

    config = Configuration.new(event.root_uri, event.capabilities, client_name)
    new_state = %__MODULE__{state | configuration: config, initialized?: true}

    event_id
    |> initialize_result()
    |> tap(fn result ->
      Logger.info("Sending initialize result: #{inspect(result)}")
    end)
    |> Transport.write()

    Transport.write(registrations())

    {:ok, new_state}
  end

  def initialize(%__MODULE__{initialized?: true}, %Requests.Initialize{}) do
    {:error, :already_initialized}
  end

  defp maybe_start_project(project, config) do
    already_started? =
      Enum.any?(config.projects, fn p ->
        p.root_uri == project.root_uri
      end)

    if already_started? do
      :ok
    else
      Logger.info("Starting project at uri #{project.root_uri}")
      result = Expert.Project.Supervisor.start(project)
      Logger.info("result: #{inspect(result)}")
      :ok
    end
  end

  def in_flight?(%__MODULE__{} = state, request_id) do
    Map.has_key?(state.in_flight_requests, request_id)
  end

  def add_request(%__MODULE__{} = state, request, callback) do
    Transport.write(request)

    in_flight_requests = Map.put(state.in_flight_requests, request.id, {request, callback})

    %__MODULE__{state | in_flight_requests: in_flight_requests}
  end

  def finish_request(%__MODULE__{} = state, response) do
    %{"id" => response_id} = response

    case Map.pop(state.in_flight_requests, response_id) do
      {{%request_module{} = request, callback}, in_flight_requests} ->
        case request_module.parse_response(response) do
          {:ok, response} ->
            callback.(request, {:ok, response.result})

          error ->
            Logger.info("failed to parse response for #{request_module}, #{inspect(error)}")
            callback.(request, error)
        end

        %__MODULE__{state | in_flight_requests: in_flight_requests}

      _ ->
        state
    end
  end

  def default_configuration(%__MODULE__{configuration: config}) do
    Configuration.default(config)
  end

  def apply(%__MODULE__{initialized?: false}, request) do
    Logger.error("Received #{request.method} before server was initialized")
    {:error, :not_initialized}
  end

  def apply(%__MODULE__{shutdown_received?: true} = state, %Notifications.Exit{}) do
    Logger.warning("Received an Exit notification. Halting the server in 150ms")
    :timer.apply_after(50, System, :halt, [0])
    {:ok, state}
  end

  def apply(%__MODULE__{shutdown_received?: true}, request) do
    Logger.error("Received #{request.method} after shutdown. Ignoring")
    {:error, :shutting_down}
  end

  def apply(%__MODULE__{} = state, %Notifications.WorkspaceDidChangeConfiguration{} = event) do
    case Configuration.on_change(state.configuration, event) do
      {:ok, config} ->
        {:ok, %__MODULE__{state | configuration: config}}

      {:ok, config, response} ->
        Transport.write(response)
        {:ok, %__MODULE__{state | configuration: config}}
    end

    {:ok, state}
  end

  def apply(%__MODULE__{} = state, %Notifications.TextDocumentDidChange{params: event}) do
    uri = event.text_document.uri
    version = event.text_document.version
    project = Project.project_for_uri(state.configuration.projects, uri)

    case Document.Store.get_and_update(
           uri,
           &Document.apply_content_changes(&1, version, event.content_changes)
         ) do
      {:ok, updated_source} ->
        updated_message =
          file_changed(
            uri: updated_source.uri,
            open?: true,
            from_version: version,
            to_version: updated_source.version
          )

        Api.broadcast(project, updated_message)
        Api.compile_document(project, updated_source)
        {:ok, state}

      error ->
        error
    end
  end

  def apply(%__MODULE__{} = state, %Notifications.TextDocumentDidOpen{} = did_open) do
    %Structures.TextDocumentItem{
      text: text,
      uri: uri,
      version: version,
      language_id: language_id
    } = did_open.params.text_document

    project = Project.find_project(uri)
    config = state.configuration

    state =
      if is_nil(project) do
        state
      else
        maybe_start_project(project, config)
        config = Configuration.add_project(config, project)
        %__MODULE__{state | configuration: config}
      end

    case Document.Store.open(uri, text, version, language_id) do
      :ok ->
        Logger.info("opened #{uri}")
        {:ok, state}

      error ->
        Logger.error("Could not open #{uri} #{inspect(error)}")
        error
    end
  end

  def apply(%__MODULE__{} = state, %Notifications.TextDocumentDidClose{params: event}) do
    uri = event.text_document.uri

    case Document.Store.close(uri) do
      :ok ->
        {:ok, state}

      error ->
        Logger.warning(
          "Received textDocument/didClose for a file that wasn't open. URI was #{uri}"
        )

        error
    end
  end

  def apply(%__MODULE__{} = state, %Notifications.TextDocumentDidSave{params: event}) do
    uri = event.text_document.uri
    project = Forge.Project.project_for_uri(state.configuration.projects, uri)

    case Document.Store.save(uri) do
      :ok ->
        Api.schedule_compile(project, false)
        {:ok, state}

      error ->
        Logger.error("Save failed for uri #{uri} error was #{inspect(error)}")
        error
    end
  end

  def apply(%__MODULE__{} = state, %Notifications.Initialized{}) do
    Logger.info("Expert Initialized")
    {:ok, %__MODULE__{state | initialized?: true}}
  end

  def apply(%__MODULE__{} = state, %Requests.Shutdown{} = shutdown) do
    Transport.write(%Response{id: shutdown.id})
    Logger.error("Shutting down")

    {:ok, %__MODULE__{state | shutdown_received?: true}}
  end

  def apply(%__MODULE__{} = state, %Notifications.WorkspaceDidChangeWatchedFiles{params: event}) do
    for project <- state.configuration.projects,
        change <- event.changes do
      event = filesystem_event(project: Project, uri: change.uri, event_type: change.type)
      Engine.Api.broadcast(project, event)
    end

    {:ok, state}
  end

  def apply(%__MODULE__{} = state, msg) do
    Logger.error("Ignoring unhandled message: #{inspect(msg)}")
    {:ok, state}
  end

  defp registrations do
    %Requests.ClientRegisterCapability{
      id: Id.next(),
      params: %Structures.RegistrationParams{
        registrations: [file_watcher_registration()]
      }
    }
  end

  @did_changed_watched_files_id "-42"
  @watched_extensions ~w(ex exs)
  defp file_watcher_registration do
    extension_glob = "{" <> Enum.join(@watched_extensions, ",") <> "}"

    watchers = [
      %Structures.FileSystemWatcher{glob_pattern: "**/mix.lock"},
      %Structures.FileSystemWatcher{glob_pattern: "**/*.#{extension_glob}"}
    ]

    %Structures.Registration{
      id: @did_changed_watched_files_id,
      method: "workspace/didChangeWatchedFiles",
      register_options: %Structures.DidChangeWatchedFilesRegistrationOptions{watchers: watchers}
    }
  end

  def initialize_result(event_id) do
    sync_options =
      %Structures.TextDocumentSyncOptions{
        open_close: true,
        change: Enumerations.TextDocumentSyncKind.incremental(),
        save: true
      }

    code_action_options =
      %Structures.CodeActionOptions{
        code_action_kinds: @supported_code_actions,
        resolve_provider: false
      }

    code_lens_options = %Structures.CodeLensOptions{resolve_provider: false}

    command_options = %Structures.ExecuteCommandOptions{
      commands: Handlers.Commands.names()
    }

    completion_options =
      %Structures.CompletionOptions{
        trigger_characters: CodeIntelligence.Completion.trigger_characters()
      }

    server_capabilities =
      %Structures.ServerCapabilities{
        code_action_provider: code_action_options,
        code_lens_provider: code_lens_options,
        completion_provider: completion_options,
        definition_provider: true,
        document_formatting_provider: true,
        document_symbol_provider: true,
        execute_command_provider: command_options,
        hover_provider: true,
        references_provider: true,
        text_document_sync: sync_options,
        workspace_symbol_provider: true
      }

    result =
      %Structures.InitializeResult{
        capabilities: server_capabilities,
        server_info: %{
          name: "Expert",
          version: "0.0.1"
        }
      }

    %Response{id: event_id, result: result}
  end
end
