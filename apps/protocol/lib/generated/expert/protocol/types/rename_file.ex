# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.RenameFile do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype annotation_id: optional(Types.ChangeAnnotation.Identifier),
          kind: literal("rename"),
          new_uri: string(),
          old_uri: string(),
          options: optional(Types.RenameFile.Options)
end
