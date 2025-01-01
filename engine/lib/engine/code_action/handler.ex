defmodule Engine.CodeAction.Handler do
  alias Lexical.Document
  alias Lexical.Document.Range
  alias Engine.CodeAction
  alias Engine.CodeAction.Diagnostic

  @callback actions(Document.t(), Range.t(), [Diagnostic.t()]) :: [CodeAction.t()]
  @callback kinds() :: [CodeAction.code_action_kind()]
end
