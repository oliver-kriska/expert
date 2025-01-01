defmodule Engine.CodeAction.Handler do
  alias Engine.Document
  alias Engine.Document.Range
  alias Engine.CodeAction
  alias Engine.CodeAction.Diagnostic

  @callback actions(Document.t(), Range.t(), [Diagnostic.t()]) :: [CodeAction.t()]
  @callback kinds() :: [CodeAction.code_action_kind()]
end
