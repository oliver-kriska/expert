# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Workspace.Symbol do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule Location do
    use Proto
    deftype uri: string()
  end

  use Proto

  deftype container_name: optional(string()),
          data: optional(any()),
          kind: Types.Symbol.Kind,
          location: one_of([Types.Location, Expert.Protocol.Types.Workspace.Symbol.Location]),
          name: string(),
          tags: optional(list_of(Types.Symbol.Tag))
end
