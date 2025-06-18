# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.ShowMessageRequest.Params do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype actions: optional(list_of(Types.Message.ActionItem)),
          message: string(),
          type: Types.Message.Type
end
