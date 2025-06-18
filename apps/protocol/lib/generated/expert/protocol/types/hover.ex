# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Hover do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype contents:
            one_of([Types.Markup.Content, Types.MarkedString, list_of(Types.MarkedString)]),
          range: optional(Types.Range)
end
