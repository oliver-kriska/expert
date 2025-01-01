defmodule Forge.Ast.Detection.Import do
  alias Forge.Ast.Analysis
  alias Forge.Ast.Detection
  alias Forge.Ast.Detection.Directive
  alias Forge.Document.Position

  use Detection

  @impl Detection
  def detected?(%Analysis{} = analysis, %Position{} = position) do
    Directive.detected?(analysis, position, ~c"import")
  end
end
