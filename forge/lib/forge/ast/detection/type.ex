defmodule Forge.Ast.Detection.Type do
  alias Forge.Ast.Analysis
  alias Forge.Ast.Detection
  alias Forge.Document.Position

  use Detection

  @impl Detection
  def detected?(%Analysis{} = analysis, %Position{} = position) do
    ancestor_is_type?(analysis, position)
  end
end
