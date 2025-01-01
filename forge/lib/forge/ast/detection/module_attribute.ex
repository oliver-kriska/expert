defmodule Forge.Ast.Detection.ModuleAttribute do
  alias Forge.Ast.Analysis
  alias Forge.Ast.Detection
  alias Forge.Document.Position

  use Detection

  @impl Detection
  def detected?(%Analysis{} = analysis, %Position{} = position) do
    ancestor_is_attribute?(analysis, position)
  end

  def detected?(%Analysis{} = analysis, %Position{} = position, name) do
    ancestor_is_attribute?(analysis, position, name)
  end
end
