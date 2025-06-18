# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.FileOperation.Pattern do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype glob: string(),
          matches: optional(Types.FileOperation.Pattern.Kind),
          options: optional(Types.FileOperation.Pattern.Options)
end
