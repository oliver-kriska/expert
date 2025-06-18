# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.WorkDone.Progress.Begin do
  alias Expert.Proto
  use Proto

  deftype cancellable: optional(boolean()),
          kind: literal("begin"),
          message: optional(string()),
          percentage: optional(integer()),
          title: string()
end
