# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Notebook.Document.Sync.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule Cells do
    use Proto
    deftype language: string()
  end

  defmodule Cells1 do
    use Proto
    deftype language: string()
  end

  defmodule NotebookSelector do
    use Proto

    deftype cells: optional(list_of(Expert.Protocol.Types.Notebook.Document.Sync.Options.Cells)),
            notebook: one_of([string(), Types.Notebook.Document.Filter])
  end

  defmodule NotebookSelector1 do
    use Proto

    deftype cells: list_of(Expert.Protocol.Types.Notebook.Document.Sync.Options.Cells1),
            notebook: optional(one_of([string(), Types.Notebook.Document.Filter]))
  end

  use Proto

  deftype notebook_selector:
            list_of(
              one_of([
                Expert.Protocol.Types.Notebook.Document.Sync.Options.NotebookSelector,
                Expert.Protocol.Types.Notebook.Document.Sync.Options.NotebookSelector1
              ])
            ),
          save: optional(boolean())
end
