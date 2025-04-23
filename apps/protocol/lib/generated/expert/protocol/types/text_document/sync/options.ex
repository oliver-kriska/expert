# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.TextDocument.Sync.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype change: optional(Types.TextDocument.Sync.Kind),
          open_close: optional(boolean()),
          save: optional(one_of([boolean(), Types.Save.Options])),
          will_save: optional(boolean()),
          will_save_wait_until: optional(boolean())
end
