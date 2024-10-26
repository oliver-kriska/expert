defmodule Namespace.ModuleTest do
  use ExUnit.Case, async: true

  setup do
    apps = [:foo, :bar, :baz]
    roots = [Foo, Bar, Engine, :something]
    [apps: apps, roots: roots]
  end

  test "namespaces a module", %{apps: apps, roots: roots} do
    assert XPFoo == Namespace.Module.run(Foo, apps: apps, roots: roots)
    assert XPEngine.Foo == Namespace.Module.run(Engine.Foo, apps: apps, roots: roots)
  end

  test "doesn't namespace a module with a different root", %{apps: apps, roots: roots} do
    refute XPFoo == Namespace.Module.run(Ding.Foo, apps: apps, roots: roots)
  end

  test "doesn't namespace an already namespaced module", %{apps: apps, roots: roots} do
    assert XPFoo == Namespace.Module.run(XPFoo, apps: apps, roots: roots)
  end

  test "namespaces app name if enabled", %{apps: apps, roots: roots} do
    assert :xp_baz == Namespace.Module.run(:baz, do_apps: true, apps: apps, roots: roots)
    assert :baz == Namespace.Module.run(:baz, do_apps: false, apps: apps, roots: roots)
  end

  test "namespaces erlang module", %{apps: apps, roots: roots} do
    assert :xp_something ==
             Namespace.Module.run(:something, do_apps: false, apps: apps, roots: roots)
  end
end
