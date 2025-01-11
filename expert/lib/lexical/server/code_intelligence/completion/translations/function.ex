defmodule Expert.CodeIntelligence.Completion.Translations.Function do
  alias Forge.Ast.Env
  alias Forge.Completion.Candidate
  alias Expert.CodeIntelligence.Completion.Translatable
  alias Expert.CodeIntelligence.Completion.Translations

  defimpl Translatable, for: Candidate.Function do
    def translate(function, _builder, %Env{} = env) do
      if Env.in_context?(env, :function_capture) do
        Translations.Callable.capture_completions(function, env)
      else
        Translations.Callable.completion(function, env)
      end
    end
  end
end
