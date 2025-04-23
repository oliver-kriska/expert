# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Document.Symbol.Params do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype partial_result_token: optional(Types.Progress.Token),
          text_document: Types.TextDocument.Identifier,
          work_done_token: optional(Types.Progress.Token)
end
