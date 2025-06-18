defmodule Forge.Ast.Detection.Spec do
  alias Forge.Ast.Analysis
  alias Forge.Ast.Detection
  alias Forge.Document.Position

  use Detection

  @impl Detection
  def detected?(%Analysis{} = analysis, %Position{} = position) do
    ancestor_is_spec?(analysis, position)
  end
end
