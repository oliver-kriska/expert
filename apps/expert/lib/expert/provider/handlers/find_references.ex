defmodule Expert.Provider.Handlers.FindReferences do
  alias Engine.Api
  alias Expert.Configuration
  alias Forge.Ast
  alias Forge.Document
  alias Forge.Project
  alias Forge.Protocol.Response
  alias GenLSP.Requests.TextDocumentReferences
  alias GenLSP.Structures

  require Logger

  def handle(
        %TextDocumentReferences{params: %Structures.ReferenceParams{} = params} = request,
        %Configuration{} = config
      ) do
    document = Forge.Document.Container.context_document(params, nil)
    project = Project.project_for_document(config.projects, document)
    include_declaration? = !!params.context.include_declaration

    locations =
      case Document.Store.fetch(document.uri, :analysis) do
        {:ok, _document, %Ast.Analysis{} = analysis} ->
          Api.references(project, analysis, params.position, include_declaration?)

        _ ->
          nil
      end

    response = %Response{id: request.id, result: locations}
    {:reply, response}
  end
end
