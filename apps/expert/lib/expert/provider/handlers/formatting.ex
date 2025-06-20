defmodule Expert.Provider.Handlers.Formatting do
  alias Expert.Configuration
  alias Forge.Document.Changes
  alias Forge.Project
  alias Forge.Protocol.Response
  alias GenLSP.Requests
  alias GenLSP.Structures

  require Logger

  def handle(
        %Requests.TextDocumentFormatting{params: %Structures.DocumentFormattingParams{} = params} =
          request,
        %Configuration{} = config
      ) do
    document = Forge.Document.Container.context_document(params, nil)
    project = Project.project_for_document(config.projects, document)

    case Engine.Api.format(project, document) do
      {:ok, %Changes{} = document_edits} ->
        response = %Response{id: request.id, result: document_edits}
        {:reply, response}

      {:error, reason} ->
        Logger.error("Formatter failed #{inspect(reason)}")
        {:reply, %Response{id: request.id, result: nil}}
    end
  end
end
