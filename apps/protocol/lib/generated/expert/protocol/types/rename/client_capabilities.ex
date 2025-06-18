# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Rename.ClientCapabilities do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype dynamic_registration: optional(boolean()),
          honors_change_annotations: optional(boolean()),
          prepare_support: optional(boolean()),
          prepare_support_default_behavior: optional(Types.PrepareSupportDefaultBehavior)
end
