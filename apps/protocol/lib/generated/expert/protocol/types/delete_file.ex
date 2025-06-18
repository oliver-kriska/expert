# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.DeleteFile do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype annotation_id: optional(Types.ChangeAnnotation.Identifier),
          kind: literal("delete"),
          options: optional(Types.DeleteFile.Options),
          uri: string()
end
