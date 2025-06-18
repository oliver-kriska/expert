# This file's contents are auto-generated. Do not edit.
defmodule Expert.Protocol.Types.Completion.List do
  alias Expert.Proto
  alias Expert.Protocol.Types

  defmodule EditRange do
    use Proto
    deftype insert: Types.Range, replace: Types.Range
  end

  defmodule ItemDefaults do
    use Proto

    deftype commit_characters: optional(list_of(string())),
            data: optional(any()),
            edit_range:
              optional(one_of([Types.Range, Expert.Protocol.Types.Completion.List.EditRange])),
            insert_text_format: optional(Types.InsertTextFormat),
            insert_text_mode: optional(Types.InsertTextMode)
  end

  use Proto

  deftype is_incomplete: boolean(),
          item_defaults: optional(Expert.Protocol.Types.Completion.List.ItemDefaults),
          items: list_of(Types.Completion.Item)
end
