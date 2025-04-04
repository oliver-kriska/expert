defmodule Lexical.Ast.Detection.SigilCSS do
  @moduledoc """
  Hard-coded throw-away module for the sake of demonstration.
  """
  alias Lexical.Ast
  alias Lexical.Ast.Analysis
  alias Lexical.Ast.Detection
  alias Lexical.Document.Position
  alias Lexical.Document.Position
  alias Lexical.Document.Range

  use Detection

  @impl Detection
  def detected?(%Analysis{} = analysis, %Position{} = position) do
    case Ast.path_at(analysis, position) do
      {:ok, path} ->
        detect_string(path, position)

      _ ->
        false
    end
  end

  defp detect_string(paths, %Position{} = position) do
    {_, detected?} =
      Macro.postwalk(paths, false, fn
        ast, false ->
          detected? = do_detect(ast, position)
          {ast, detected?}

        ast, true ->
          {ast, true}
      end)

    detected?
  end

  # String sigils
  defp do_detect({sigil, _, _} = ast, %Position{} = position)
       when sigil in [:sigil_css, :sigil_CSS] do
    case fetch_range(ast, 0, 0) do
      {:ok, range} -> Range.contains?(range, position)
      _ -> false
    end
  end

  defp do_detect(_, _), do: false
end
