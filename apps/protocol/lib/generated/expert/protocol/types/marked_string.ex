# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.MarkedString do
  alias Expert.Proto

  defmodule MarkedString do
    use Proto
    deftype language: string(), value: string()
  end

  use Proto
  defalias one_of([string(), Expert.Protocol.Types.MarkedString.MarkedString])
end
