# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.General.ClientCapabilities do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule StaleRequestSupport do
    use Proto
    deftype cancel: boolean(), retry_on_content_modified: list_of(string())
  end

  use Proto

  deftype markdown: optional(Types.Markdown.ClientCapabilities),
          position_encodings: optional(list_of(Types.Position.Encoding.Kind)),
          regular_expressions: optional(Types.RegularExpressions.ClientCapabilities),
          stale_request_support:
            optional(Expert.Protocol.Types.General.ClientCapabilities.StaleRequestSupport)
end
