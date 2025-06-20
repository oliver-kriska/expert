defmodule Expert.Provider.Handlers.GoToDefinition do
  alias Expert.Configuration
  alias Forge.Project
  alias Forge.Protocol.Response
  alias GenLSP.Requests
  alias GenLSP.Structures

  require Logger

  def handle(
        %Requests.TextDocumentDefinition{
          params: %Structures.DefinitionParams{} = params
        } = request,
        %Configuration{} = config
      ) do
    document = Forge.Document.Container.context_document(params, nil)
    project = Project.project_for_document(config.projects, document)

    case Engine.Api.definition(project, document, params.position) do
      {:ok, native_location} ->
        {:reply, %Response{id: request.id, result: native_location}}

      {:error, reason} ->
        Logger.error("GoToDefinition failed: #{inspect(reason)}")
        {:reply, %Response{id: request.id, result: nil}}
    end
  end
end
