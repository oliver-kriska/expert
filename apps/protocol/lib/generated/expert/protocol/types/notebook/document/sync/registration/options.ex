# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Notebook.Document.Sync.Registration.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule Cells2 do
    use Proto
    deftype language: string()
  end

  defmodule Cells3 do
    use Proto
    deftype language: string()
  end

  defmodule NotebookSelector2 do
    use Proto

    deftype cells:
              optional(
                list_of(Expert.Protocol.Types.Notebook.Document.Sync.Registration.Options.Cells2)
              ),
            notebook: one_of([string(), Types.Notebook.Document.Filter])
  end

  defmodule NotebookSelector3 do
    use Proto

    deftype cells:
              list_of(Expert.Protocol.Types.Notebook.Document.Sync.Registration.Options.Cells3),
            notebook: optional(one_of([string(), Types.Notebook.Document.Filter]))
  end

  use Proto

  deftype id: optional(string()),
          notebook_selector:
            list_of(
              one_of([
                Expert.Protocol.Types.Notebook.Document.Sync.Registration.Options.NotebookSelector2,
                Expert.Protocol.Types.Notebook.Document.Sync.Registration.Options.NotebookSelector3
              ])
            ),
          save: optional(boolean())
end
