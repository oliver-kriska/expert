defmodule Expert.Provider.Handlers.Completion do
  alias Lexical.Ast
  alias Forge.Document
  alias Forge.Document.Position
  alias GenLSP.Structures.CompletionContext
  alias Expert.CodeIntelligence
  alias Expert.Configuration

  require Logger

  def handle(%Requests.Completion{} = request, %Configuration{} = config) do
    completions =
      CodeIntelligence.Completion.complete(
        config.project,
        document_analysis(request.document, request.position),
        request.position,
        request.context ||
          %CompletionContext{trigger_kind: GenLSP.Enumerations.CompletionTriggerKind.invoked()}
      )

    response = Responses.Completion.new(request.id, completions)
    {:reply, response}
  end

  defp document_analysis(%Document{} = document, %Position{} = position) do
    case Document.Store.fetch(document.uri, :analysis) do
      {:ok, %Document{}, %Ast.Analysis{} = analysis} ->
        Ast.reanalyze_to(analysis, position)

      _ ->
        document
        |> Ast.analyze()
        |> Ast.reanalyze_to(position)
    end
  end
end
