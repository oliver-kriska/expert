defmodule Expert.CodeIntelligence.Completion.Translations.Typespec do
  alias Forge.Completion.Candidate
  alias Expert.CodeIntelligence.Completion.Translatable
  alias Expert.CodeIntelligence.Completion.Translations.Callable
  alias Forge.Ast.Env

  defimpl Translatable, for: Candidate.Typespec do
    def translate(typespec, _builder, %Env{} = env) do
      Callable.completion(typespec, env)
    end
  end
end
