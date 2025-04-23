defmodule Forge.Ast.Detection.Directive do
  alias Forge.Ast.Analysis
  alias Forge.Ast.Tokens
  alias Forge.Document.Position

  def detected?(%Analysis{} = analysis, %Position{} = position, directive_type) do
    analysis.document
    |> Tokens.prefix_stream(position)
    |> Enum.to_list()
    |> Enum.reduce_while(false, fn
      {:identifier, ^directive_type, _}, _ ->
        {:halt, true}

      {:eol, _, _}, _ ->
        {:halt, false}

      _, _ ->
        {:cont, false}
    end)
  end
end
