defmodule Forge.Ast.Detection.BitstringTest do
  use Forge.Test.DetectionCase,
    for: Forge.Ast.Detection.Bitstring,
    assertions: [[:bitstring, :*]],
    variations: [:match, :function_arguments, :function_body]
end
