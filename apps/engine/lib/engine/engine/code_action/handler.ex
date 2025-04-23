defmodule Engine.CodeAction.Handler do
  alias Forge.Document
  alias Forge.Document.Range
  alias Engine.CodeAction
  alias Engine.CodeAction.Diagnostic

  @callback actions(Document.t(), Range.t(), [Diagnostic.t()]) :: [CodeAction.t()]
  @callback kinds() :: [CodeAction.code_action_kind()]
  @callback trigger_kind() :: CodeAction.trigger_kind() | :all
end
