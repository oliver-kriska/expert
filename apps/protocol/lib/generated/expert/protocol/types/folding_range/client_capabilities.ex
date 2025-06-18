# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.FoldingRange.ClientCapabilities do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule FoldingRange do
    use Proto
    deftype collapsed_text: optional(boolean())
  end

  defmodule FoldingRangeKind do
    use Proto
    deftype value_set: optional(list_of(Types.FoldingRange.Kind))
  end

  use Proto

  deftype dynamic_registration: optional(boolean()),
          folding_range:
            optional(Expert.Protocol.Types.FoldingRange.ClientCapabilities.FoldingRange),
          folding_range_kind:
            optional(Expert.Protocol.Types.FoldingRange.ClientCapabilities.FoldingRangeKind),
          line_folding_only: optional(boolean()),
          range_limit: optional(integer())
end
