# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.CodeAction do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule Disabled do
    use Proto
    deftype reason: string()
  end

  use Proto

  deftype command: optional(Types.Command),
          data: optional(any()),
          diagnostics: optional(list_of(Types.Diagnostic)),
          disabled: optional(Expert.Protocol.Types.CodeAction.Disabled),
          edit: optional(Types.Workspace.Edit),
          is_preferred: optional(boolean()),
          kind: optional(Types.CodeAction.Kind),
          title: string()
end
