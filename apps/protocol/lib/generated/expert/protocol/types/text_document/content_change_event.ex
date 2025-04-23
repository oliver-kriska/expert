# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.TextDocument.ContentChangeEvent do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule TextDocumentContentChangeEvent do
    use Proto
    deftype range: Types.Range, range_length: optional(integer()), text: string()
  end

  defmodule TextDocumentContentChangeEvent1 do
    use Proto
    deftype text: string()
  end

  use Proto

  defalias one_of([
             Expert.Protocol.Types.TextDocument.ContentChangeEvent.TextDocumentContentChangeEvent,
             Expert.Protocol.Types.TextDocument.ContentChangeEvent.TextDocumentContentChangeEvent1
           ])
end
