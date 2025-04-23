defmodule Forge.Ast.Detection.UseTest do
  alias Forge.Ast.Detection

  use Forge.Test.DetectionCase,
    for: Detection.Use,
    assertions: [[:use, :*]]
end
