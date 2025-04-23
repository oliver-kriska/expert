# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Hover.Params do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype position: Types.Position,
          text_document: Types.TextDocument.Identifier,
          work_done_token: optional(Types.Progress.Token)
end
