# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Location.Link do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype origin_selection_range: optional(Types.Range),
          target_range: Types.Range,
          target_selection_range: Types.Range,
          target_uri: string()
end
