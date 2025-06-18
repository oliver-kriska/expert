defmodule Forge.Ast.Detection.SpecTest do
  alias Forge.Ast.Detection

  use Forge.Test.DetectionCase,
    for: Detection.Spec,
    assertions: [[:spec, :*]]
end
