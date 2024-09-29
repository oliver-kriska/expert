defmodule NamespaceTest do
  use ExUnit.Case
  doctest Namespace

  test "greets the world" do
    assert Namespace.hello() == :world
  end
end
