defmodule ExpertTest do
  use ExUnit.Case
  doctest Expert

  test "greets the world" do
    assert Expert.hello() == :world
  end
end
