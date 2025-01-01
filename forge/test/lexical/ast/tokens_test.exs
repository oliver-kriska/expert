defmodule Forge.Ast.TokensTest do
  alias Forge.Ast.Tokens

  import Forge.Test.CodeSigil
  import Forge.Test.CursorSupport

  use ExUnit.Case, async: true

  describe "prefix_stream/2" do
    test "works as intended" do
      text = ~q[
        defmodule Foo do
          def bar do
            |
          end
        end
      ]

      {position, document} = pop_cursor(text, as: :document)

      tokens = Tokens.prefix_stream(document, position)

      assert Enum.to_list(tokens) == [
               {:eol, ~c"\n", []},
               {:operator, :do, {2, 11}},
               {:do_identifier, ~c"bar", {2, 7}},
               {:identifier, ~c"def", {2, 3}},
               {:eol, ~c"\n", []},
               {:operator, :do, {1, 15}},
               {:alias, ~c"Foo", {1, 11}},
               {:identifier, ~c"defmodule", {1, 1}}
             ]
    end

    test "returns nothing when cursor is at start" do
      text = ~q[
        |defmodule Foo do
          def bar do
            :bar
          end
        end
      ]

      {position, document} = pop_cursor(text, as: :document)

      tokens = Tokens.prefix_stream(document, position)

      assert Enum.to_list(tokens) == []
    end
  end
end
