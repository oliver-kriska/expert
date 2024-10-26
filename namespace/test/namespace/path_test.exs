defmodule Namespace.PathTest do
  use ExUnit.Case, async: true

  setup do
    apps = [:foo, :bar, :baz]
    roots = [Foo, Bar, Engine]
    [apps: apps, roots: roots]
  end

  test "namespaces charlist path", %{apps: apps, roots: roots} do
    assert ~c"hello/xp_foo/ebin" ==
             Namespace.Path.run(~c"hello/foo/ebin", do_apps: true, apps: apps, roots: roots)
  end

  test "doesn't namespace if do_apps is false", %{apps: apps, roots: roots} do
    assert ~c"hello/foo/ebin" ==
             Namespace.Path.run(~c"hello/foo/ebin", do_apps: false, apps: apps, roots: roots)
  end
end
