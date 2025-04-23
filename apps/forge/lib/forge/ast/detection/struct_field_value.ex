defmodule Forge.Ast.Detection.StructFieldValue do
  alias Forge.Ast.Analysis
  alias Forge.Ast.Detection.StructFieldKey
  alias Forge.Ast.Detection.StructFields
  alias Forge.Document.Position

  def detected?(%Analysis{} = analysis, %Position{} = position) do
    StructFields.detected?(analysis, position) and
      not StructFieldKey.detected?(analysis, position)
  end
end
