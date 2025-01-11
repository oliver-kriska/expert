defmodule Forge.CodeAction.Handler do
  alias Forge.Document
  alias Forge.Document.Range
  alias Forge.CodeAction
  alias Forge.CodeAction.Diagnostic

  @callback actions(Document.t(), Range.t(), [Diagnostic.t()]) :: [CodeAction.t()]
  @callback kinds() :: [CodeAction.code_action_kind()]
end
