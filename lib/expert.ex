defmodule Expert do
  use GenLSP
  require Logger

  def start_link(opts) do
    GenLSP.start_link(__MODULE__, [], opts)
  end

  @impl true
  def init(lsp, _args) do
    {:ok,
     assign(lsp,
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
    workspace_folders =
      if caps.workspace.workspace_folders do
        workspace_folders
      else
        [%{name: Path.basename(root_uri), uri: root_uri}]
      end

    {:reply,
     %GenLSP.Structures.InitializeResult{
       capabilities: %GenLSP.Structures.ServerCapabilities{
         text_document_sync: %GenLSP.Structures.TextDocumentSyncOptions{
           open_close: true,
           save: %GenLSP.Structures.SaveOptions{include_text: true},
           change: GenLSP.Enumerations.TextDocumentSyncKind.incremental()
         },
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

  def handle_request(_request, lsp) do
    {:noreply, lsp}
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

  def version do
    case :application.get_key(:expert, :vsn) do
      {:ok, version} -> to_string(version)
      _ -> "dev"
    end
  end
end
