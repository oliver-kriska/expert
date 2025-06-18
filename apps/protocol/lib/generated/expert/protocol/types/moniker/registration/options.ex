# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Moniker.Registration.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype document_selector: one_of([Types.Document.Selector, nil]),
          work_done_progress: optional(boolean())
end
