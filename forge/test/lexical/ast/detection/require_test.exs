defmodule Forge.Ast.Detection.RequireTest do
  alias Forge.Ast.Detection

  use Forge.Test.DetectionCase,
    for: Detection.Require,
    assertions: [[:require, :*]]
end
