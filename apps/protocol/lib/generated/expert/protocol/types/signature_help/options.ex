# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.SignatureHelp.Options do
  alias Expert.Proto
  use Proto

  deftype retrigger_characters: optional(list_of(string())),
          trigger_characters: optional(list_of(string())),
          work_done_progress: optional(boolean())
end
