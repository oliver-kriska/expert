defmodule Forge.Ast.Detection.CommentTest do
  alias Forge.Ast.Detection

  use Forge.Test.DetectionCase,
    for: Detection.Comment,
    assertions: [[:comment, :*]]
end
