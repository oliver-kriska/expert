# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.InlayHint.ClientCapabilities do
  alias Expert.Proto

  defmodule ResolveSupport do
    use Proto
    deftype properties: list_of(string())
  end

  use Proto

  deftype dynamic_registration: optional(boolean()),
          resolve_support:
            optional(Expert.Protocol.Types.InlayHint.ClientCapabilities.ResolveSupport)
end
