# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.CodeAction.Kind do
  alias Expert.Proto
  use Proto

  defenum empty: "",
          quick_fix: "quickfix",
          refactor: "refactor",
          refactor_extract: "refactor.extract",
          refactor_inline: "refactor.inline",
          refactor_rewrite: "refactor.rewrite",
          source: "source",
          source_organize_imports: "source.organizeImports",
          source_fix_all: "source.fixAll"
end
