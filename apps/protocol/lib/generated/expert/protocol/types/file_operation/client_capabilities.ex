# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.FileOperation.ClientCapabilities do
  alias Expert.Proto
  use Proto

  deftype did_create: optional(boolean()),
          did_delete: optional(boolean()),
          did_rename: optional(boolean()),
          dynamic_registration: optional(boolean()),
          will_create: optional(boolean()),
          will_delete: optional(boolean()),
          will_rename: optional(boolean())
end
