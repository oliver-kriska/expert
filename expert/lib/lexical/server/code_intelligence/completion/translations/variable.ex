defmodule Expert.CodeIntelligence.Completion.Translations.Variable do
  alias Lexical.Ast.Env
  alias Engine.Completion.Candidate
  alias Expert.CodeIntelligence.Completion.SortScope
  alias Expert.CodeIntelligence.Completion.Translatable

  defimpl Translatable, for: Candidate.Variable do
    def translate(variable, builder, %Env{} = env) do
      env
      |> builder.plain_text(variable.name,
        detail: variable.name,
        kind: :variable,
        label: variable.name
      )
      |> builder.set_sort_scope(SortScope.variable())
    end
  end
end
