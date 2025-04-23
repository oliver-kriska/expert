# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Window.ClientCapabilities do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype show_document: optional(Types.ShowDocument.ClientCapabilities),
          show_message: optional(Types.ShowMessageRequest.ClientCapabilities),
          work_done_progress: optional(boolean())
end
