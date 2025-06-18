# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.CreateFile do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype annotation_id: optional(Types.ChangeAnnotation.Identifier),
          kind: literal("create"),
          options: optional(Types.CreateFile.Options),
          uri: string()
end
