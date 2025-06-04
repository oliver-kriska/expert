defmodule Expert.Provider.Handlers.CodeAction do
  alias Engine.CodeAction
  alias Expert.Configuration
  alias Expert.Protocol.Response
  alias GenLSP.Requests
  alias GenLSP.Structures

  def handle(
        %Requests.TextDocumentCodeAction{params: %Structures.CodeActionParams{} = params} =
          request,
        %Configuration{} = config
      ) do
    document = Lexical.Document.Container.context_document(params, nil)
    diagnostics = Enum.map(params.context.diagnostics, &to_code_action_diagnostic/1)

    code_actions =
      Engine.Api.code_actions(
        config.project,
        document,
        params.range,
        diagnostics,
        params.context.only || :all,
        params.context.trigger_kind
      )

    results = Enum.map(code_actions, &to_result/1)
    reply = %Response{id: request.id, result: results}

    {:reply, reply}
  end

  defp to_code_action_diagnostic(%Structures.Diagnostic{} = diagnostic) do
    %Structures.Diagnostic{
      range: diagnostic.range,
      message: diagnostic.message,
      source: diagnostic.source
    }
  end

  defp to_result(%CodeAction{} = action) do
    %Structures.CodeAction{
      title: action.title,
      kind: action.kind,
      edit: %Structures.WorkspaceEdit{changes: %{action.uri => action.changes}}
    }
  end
end
