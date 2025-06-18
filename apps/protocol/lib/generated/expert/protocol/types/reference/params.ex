# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Reference.Params do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype context: Types.Reference.Context,
          partial_result_token: optional(Types.Progress.Token),
          position: Types.Position,
          text_document: Types.TextDocument.Identifier,
          work_done_token: optional(Types.Progress.Token)
end
