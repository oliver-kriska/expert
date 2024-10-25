defmodule Namespace.ModuleTest do
  use ExUnit.Case, async: true

  setup do
    apps = [:foo, :bar, :baz]
    roots = [Foo, Bar, Engine]
    [apps: apps, roots: roots]
  end

  test "namespaces a module", %{apps: apps, roots: roots} do
    assert XPFoo == Namespace.Module.run(Foo, apps: apps, roots: roots)
    assert :xp_baz == Namespace.Module.run(:baz, apps: apps, roots: roots)
    assert XPert.Foo == Namespace.Module.run(Engine.Foo, apps: apps, roots: roots)
  end

  test "doesn't namespace a module with a different root", %{apps: apps, roots: roots} do
    refute XPFoo == Namespace.Module.run(Ding.Foo, apps: apps, roots: roots)
  end

  test "doesnt namespace an already namespaced module", %{apps: apps, roots: roots} do
    assert XPFoo == Namespace.Module.run(XPFoo, apps: apps, roots: roots)
    assert :xp_baz == Namespace.Module.run(:xp_baz, apps: apps, roots: roots)
  end
end
