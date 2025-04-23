# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Document.Symbol do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype children: optional(list_of(Types.Document.Symbol)),
          deprecated: optional(boolean()),
          detail: optional(string()),
          kind: Types.Symbol.Kind,
          name: string(),
          range: Types.Range,
          selection_range: Types.Range,
          tags: optional(list_of(Types.Symbol.Tag))
end
