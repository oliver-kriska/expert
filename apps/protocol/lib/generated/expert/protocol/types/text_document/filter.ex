# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.TextDocument.Filter do
  alias Expert.Proto

  defmodule TextDocumentFilter do
    use Proto
    deftype language: string(), pattern: optional(string()), scheme: optional(string())
  end

  defmodule TextDocumentFilter1 do
    use Proto
    deftype language: optional(string()), pattern: optional(string()), scheme: string()
  end

  defmodule TextDocumentFilter2 do
    use Proto
    deftype language: optional(string()), pattern: string(), scheme: optional(string())
  end

  use Proto

  defalias one_of([
             Expert.Protocol.Types.TextDocument.Filter.TextDocumentFilter,
             Expert.Protocol.Types.TextDocument.Filter.TextDocumentFilter1,
             Expert.Protocol.Types.TextDocument.Filter.TextDocumentFilter2
           ])
end
