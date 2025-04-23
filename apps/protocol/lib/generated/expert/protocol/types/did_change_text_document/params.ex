# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.DidChangeTextDocument.Params do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype content_changes: list_of(Types.TextDocument.ContentChangeEvent),
          text_document: Types.TextDocument.Versioned.Identifier
end
