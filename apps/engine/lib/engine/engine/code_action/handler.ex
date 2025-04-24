defmodule Engine.CodeAction.Handler do
  alias Engine.CodeAction
  alias Engine.CodeAction.Diagnostic
  alias Forge.Document
  alias Forge.Document.Range

  @callback actions(Document.t(), Range.t(), [Diagnostic.t()]) :: [CodeAction.t()]
  @callback kinds() :: [CodeAction.code_action_kind()]
  @callback trigger_kind() :: CodeAction.trigger_kind() | :all
end
