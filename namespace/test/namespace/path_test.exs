defmodule Namespace.PathTest do
  use ExUnit.Case, async: true

  setup do
    apps = [:foo, :bar, :baz]
    roots = [Foo, Bar, Engine]
    [apps: apps, roots: roots]
  end

  test "namespaces charlist path", %{apps: apps, roots: roots} do
    assert ~c"hello/xp_foo/ebin" ==
             Namespace.Path.run(~c"hello/foo/ebin", apps: apps, roots: roots)
  end
end
