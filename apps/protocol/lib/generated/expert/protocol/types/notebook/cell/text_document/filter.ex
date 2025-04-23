# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Notebook.Cell.TextDocument.Filter do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype language: optional(string()),
          notebook: one_of([string(), Types.Notebook.Document.Filter])
end
