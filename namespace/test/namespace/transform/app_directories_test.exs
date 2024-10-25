defmodule Namespace.Transform.AppDirectoriesTest do
  use ExUnit.Case, async: true

  @moduletag tmp_dir: true
  setup do
    apps = [:foo, :bar, :baz]
    roots = [Foo, Bar, Engine]
    [apps: apps, roots: roots]
  end

  test "renames the app directory", %{tmp_dir: dir, apps: apps, roots: roots} do
    File.mkdir_p!(Path.join(dir, "lib/bar/ebin"))
    File.mkdir_p!(Path.join(dir, "lib/foo/ebin"))
    File.mkdir_p!(Path.join(dir, "lib/bob/ebin"))

    Namespace.Transform.AppDirectories.run_all(dir, apps: apps, roots: roots)

    refute File.exists?(Path.join(dir, "lib/bar/ebin/"))
    assert File.exists?(Path.join(dir, "lib/xp_bar/ebin/"))
    assert File.exists?(Path.join(dir, "lib/xp_foo/ebin/"))

    # doesn't run on dirs for apps not listed
    assert File.exists?(Path.join(dir, "lib/bob/ebin/"))
    refute File.exists?(Path.join(dir, "lib/xp_bob/ebin/"))
  end
end
