# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.PublishDiagnostics.ClientCapabilities do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule TagSupport do
    use Proto
    deftype value_set: list_of(Types.Diagnostic.Tag)
  end

  use Proto

  deftype code_description_support: optional(boolean()),
          data_support: optional(boolean()),
          related_information: optional(boolean()),
          tag_support:
            optional(Expert.Protocol.Types.PublishDiagnostics.ClientCapabilities.TagSupport),
          version_support: optional(boolean())
end
