defmodule Expert.Provider.Handlers.CodeAction do
  alias GenLSP.Requests.TextDocumentCodeAction
  alias GenLSP.Structures.Diagnostic
  alias GenLSP.Structures.WorkspaceEdit
  alias Forge.CodeAction
  alias Expert.Configuration

  require Logger

  def handle(%TextDocumentCodeAction{} = request, %Configuration{} = config) do
    diagnostics = Enum.map(request.context.diagnostics, &to_code_action_diagnostic/1)

    code_actions =
      Engine.Api.code_actions(
        config.project,
        request.document,
        request.range,
        diagnostics,
        request.context.only || :all
      )

    results = Enum.map(code_actions, &to_result/1)
    reply = Responses.CodeAction.new(request.id, results)

    {:reply, reply}
  end

  defp to_code_action_diagnostic(%Diagnostic{} = diagnostic) do
    CodeAction.Diagnostic.new(diagnostic.range, diagnostic.message, diagnostic.source)
  end

  defp to_result(%CodeAction{} = action) do
    Types.CodeAction.new(
      title: action.title,
      kind: action.kind,
      edit: Workspace.Edit.new(changes: %{action.uri => action.changes})
    )
  end
end
