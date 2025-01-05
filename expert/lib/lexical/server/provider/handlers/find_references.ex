defmodule Expert.Provider.Handlers.FindReferences do
  alias Lexical.Ast
  alias Forge.Document
  alias Lexical.Protocol.Requests.FindReferences
  alias Lexical.Protocol.Responses
  alias Engine.Api
  alias Expert.Configuration

  require Logger

  def handle(%FindReferences{} = request, %Configuration{} = config) do
    include_declaration? = !!request.context.include_declaration

    locations =
      case Document.Store.fetch(request.document.uri, :analysis) do
        {:ok, _document, %Ast.Analysis{} = analysis} ->
          Api.references(config.project, analysis, request.position, include_declaration?)

        _ ->
          nil
      end

    response = Responses.FindReferences.new(request.id, locations)
    {:reply, response}
  end
end
