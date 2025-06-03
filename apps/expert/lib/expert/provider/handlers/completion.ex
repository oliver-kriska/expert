defmodule Expert.Provider.Handlers.Completion do
  alias Expert.CodeIntelligence
  alias Expert.Configuration
  alias Expert.Protocol.Response
  alias Forge.Ast
  alias Forge.Document
  alias Forge.Document.Position
  alias GenLSP.Requests
  alias GenLSP.Structures
  alias GenLSP.Structures.CompletionContext
  alias GenLSP.Enumerations.CompletionTriggerKind

  require Logger

  def handle(
        %Requests.TextDocumentCompletion{
          params: %Structures.CompletionParams{} = params
        } = request,
        %Configuration{} = config
      ) do
    document = Document.Container.context_document(params, nil)

    completions =
      CodeIntelligence.Completion.complete(
        config.project,
        document_analysis(document, params.position),
        params.position,
        params.context || %CompletionContext{trigger_kind: CompletionTriggerKind.invoked()}
      )

    response = %Response{id: request.id, result: completions}
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
