# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.FileOperation.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype did_create: optional(Types.FileOperation.Registration.Options),
          did_delete: optional(Types.FileOperation.Registration.Options),
          did_rename: optional(Types.FileOperation.Registration.Options),
          will_create: optional(Types.FileOperation.Registration.Options),
          will_delete: optional(Types.FileOperation.Registration.Options),
          will_rename: optional(Types.FileOperation.Registration.Options)
end
