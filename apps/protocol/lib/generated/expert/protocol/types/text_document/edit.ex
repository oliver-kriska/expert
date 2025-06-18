# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.TextDocument.Edit do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype edits: list_of(one_of([Types.TextEdit, Types.TextEdit.Annotated])),
          text_document: Types.TextDocument.OptionalVersioned.Identifier
end
