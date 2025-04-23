# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Diagnostic.Registration.Options do
  alias Expert.Proto
  alias Expert.Protocol.Types
  use Proto

  deftype document_selector: one_of([Types.Document.Selector, nil]),
          id: optional(string()),
          identifier: optional(string()),
          inter_file_dependencies: boolean(),
          work_done_progress: optional(boolean()),
          workspace_diagnostics: boolean()
end
