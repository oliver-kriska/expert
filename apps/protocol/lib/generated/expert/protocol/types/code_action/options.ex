# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.CodeAction.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype code_action_kinds: optional(list_of(Types.CodeAction.Kind)),
          resolve_provider: optional(boolean()),
          work_done_progress: optional(boolean())
end
