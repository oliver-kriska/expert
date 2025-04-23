# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.TextDocument.Sync.ClientCapabilities do
  alias Expert.Proto
  use Proto

  deftype did_save: optional(boolean()),
          dynamic_registration: optional(boolean()),
          will_save: optional(boolean()),
          will_save_wait_until: optional(boolean())
end
