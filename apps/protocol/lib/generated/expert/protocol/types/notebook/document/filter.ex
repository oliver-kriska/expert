# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Notebook.Document.Filter do
  alias Expert.Proto

  defmodule NotebookDocumentFilter do
    use Proto
    deftype notebook_type: string(), pattern: optional(string()), scheme: optional(string())
  end

  defmodule NotebookDocumentFilter1 do
    use Proto
    deftype notebook_type: optional(string()), pattern: optional(string()), scheme: string()
  end

  defmodule NotebookDocumentFilter2 do
    use Proto
    deftype notebook_type: optional(string()), pattern: string(), scheme: optional(string())
  end

  use Proto

  defalias one_of([
             Expert.Protocol.Types.Notebook.Document.Filter.NotebookDocumentFilter,
             Expert.Protocol.Types.Notebook.Document.Filter.NotebookDocumentFilter1,
             Expert.Protocol.Types.Notebook.Document.Filter.NotebookDocumentFilter2
           ])
end
