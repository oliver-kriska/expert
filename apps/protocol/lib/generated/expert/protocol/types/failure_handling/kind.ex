# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.FailureHandling.Kind do
  alias Expert.Proto
  use Proto

  defenum abort: "abort",
          transactional: "transactional",
          text_only_transactional: "textOnlyTransactional",
          undo: "undo"
end
