defmodule Forge.Ast.Detection.AliasTest do
  alias Forge.Ast.Detection

  use Forge.Test.DetectionCase,
    for: Detection.Alias,
    assertions: [[:alias, :*]]
end
