defmodule Forge.Ast.Detection.Comment do
  alias Forge.Ast.Analysis
  alias Forge.Document.Position

  def detected?(%Analysis{} = analysis, %Position{} = position) do
    Analysis.commented?(analysis, position)
  end
end
