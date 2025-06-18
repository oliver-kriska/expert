# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.SemanticTokens.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule Full do
    use Proto
    deftype delta: optional(boolean())
  end

  defmodule Range do
    use Proto
    deftype []
  end

  use Proto

  deftype full: optional(one_of([boolean(), Expert.Protocol.Types.SemanticTokens.Options.Full])),
          legend: Types.SemanticTokens.Legend,
          range:
            optional(one_of([boolean(), Expert.Protocol.Types.SemanticTokens.Options.Range])),
          work_done_progress: optional(boolean())
end
