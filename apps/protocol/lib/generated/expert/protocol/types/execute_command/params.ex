# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.ExecuteCommand.Params do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype arguments: optional(list_of(any())),
          command: string(),
          work_done_token: optional(Types.Progress.Token)
end
