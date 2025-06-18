# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Workspace.FoldersServerCapabilities do
  alias Expert.Proto
  use Proto

  deftype change_notifications: optional(one_of([string(), boolean()])),
          supported: optional(boolean())
end
