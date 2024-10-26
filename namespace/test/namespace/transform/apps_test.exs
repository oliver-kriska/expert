defmodule Namespace.Transform.AppsTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @app """
  {application,some_app,
           [{config_mtime,1727544388},
     {optional_applications,[]},
     {applications,[kernel,stdlib,elixir,logger,sasl]},
     {description,"namespace"},
     {modules,['Elixir.SomeApp.Alice',
              'Elixir.SomeApp.Bob',
              'Elixir.AnotherApp.Foo',
              'Elixir.SomeApp.Carol']},
    {registered,[]},
    {vsn,"0.1.0"}]}.
  """
  @moduletag tmp_dir: true
  setup %{tmp_dir: dir} do
    apps = [:some_app]
    roots = [SomeApp]
    path = Path.join(dir, "some/folder/path")
    File.mkdir_p!(path)
    File.write!(Path.join(path, "some_app.app"), @app)
    [apps: apps, roots: roots, path: path]
  end

  test "namespaces .app files", %{tmp_dir: dir, apps: apps, roots: roots} do
    {_, io} =
      with_io(fn ->
        Namespace.Transform.Apps.run_all(dir, do_apps: true, apps: apps, roots: roots)
      end)

    assert io =~ "Rewriting 1 app files"

    assert """
           {application,xp_some_app,
                        [{config_mtime,1727544388},
                         {optional_applications,[]},
                         {applications,[kernel,stdlib,elixir,logger,sasl]},
                         {description,"namespace namespaced by expert."},
                         {modules,['Elixir.XPSomeApp.Alice','Elixir.XPSomeApp.Bob',
                                   'Elixir.AnotherApp.Foo','Elixir.XPSomeApp.Carol']},
                         {registered,[]},
                         {vsn,"0.1.0"}]}.
           """ == File.read!(Path.join(dir, "some/folder/path/xp_some_app.app"))
  end

  test "doesn't namespace the actual app, only the modules", %{
    tmp_dir: dir,
    apps: apps,
    roots: roots
  } do
    {_, io} =
      with_io(fn ->
        Namespace.Transform.Apps.run_all(dir, do_apps: false, apps: apps, roots: roots)
      end)

    assert io =~ "Rewriting 1 app files"

    assert """
           {application,some_app,
                        [{config_mtime,1727544388},
                         {optional_applications,[]},
                         {applications,[kernel,stdlib,elixir,logger,sasl]},
                         {description,"namespace namespaced by expert."},
                         {modules,['Elixir.XPSomeApp.Alice','Elixir.XPSomeApp.Bob',
                                   'Elixir.AnotherApp.Foo','Elixir.XPSomeApp.Carol']},
                         {registered,[]},
                         {vsn,"0.1.0"}]}.
           """ == File.read!(Path.join(dir, "some/folder/path/some_app.app"))
  end
end
