# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Initialize.Result do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule ServerInfo do
    use Proto
    deftype name: string(), version: optional(string())
  end

  use Proto

  deftype capabilities: Types.ServerCapabilities,
          server_info: optional(Expert.Protocol.Types.Initialize.Result.ServerInfo)
end
