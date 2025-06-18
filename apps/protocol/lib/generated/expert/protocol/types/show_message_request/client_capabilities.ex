# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.ShowMessageRequest.ClientCapabilities do
  alias Expert.Proto

  defmodule MessageActionItem do
    use Proto
    deftype additional_properties_support: optional(boolean())
  end

  use Proto

  deftype message_action_item:
            optional(
              Expert.Protocol.Types.ShowMessageRequest.ClientCapabilities.MessageActionItem
            )
end
