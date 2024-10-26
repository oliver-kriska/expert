defmodule Namespace.Transform.BeamsTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @moduletag tmp_dir: true
  setup %{tmp_dir: dir} do
    apps = [:some_app, :bar]
    roots = [SomeApp, Engine, Bar]
    path = Path.join(dir, "lib/some_app/ebin")
    File.mkdir_p!(path)
    [apps: apps, roots: roots, path: path]
  end

  test "rewrites the abstract code in the beam file", %{
    tmp_dir: dir,
    apps: apps,
    roots: roots,
    path: path
  } do
    File.cp!(
      "_build/test/lib/namespace/ebin/Elixir.SomeApp.beam",
      Path.join(path, "Elixir.SomeApp.beam")
    )

    {_, io} =
      with_io(fn ->
        Namespace.Transform.Beams.run_all(dir, do_apps: true, apps: apps, roots: roots)
      end)

    assert io =~ "Rewriting .beam files"
    assert io =~ "Found 1 app beam files"
    assert io =~ "Applying namespace:"
    assert io =~ "done"

    assert File.exists?(Path.join(path, "Elixir.XPSomeApp.beam"))

    {:ok, funcs} =
      Namespace.Abstract.code_from(
        Path.join(path, "Elixir.XPSomeApp.beam")
        |> String.to_charlist()
      )

    funcs =
      funcs
      |> Enum.filter(fn x -> match?({:function, _, _, _, _}, x) end)
      |> Map.new(fn
        {:function, _, name, arity, body} -> {{name, arity}, body}
        _ -> nil
      end)

    assert funcs[{:run, 0}] == [
             {:clause, 24, [], [],
              [
                {:call, 25, {:atom, 25, :another}, []},
                {:call, 26, {:remote, 26, {:atom, 26, XPEngine}, {:atom, 26, :thing}}, []}
              ]}
           ]

    assert funcs[{:another, 0}] == [
             {
               :clause,
               29,
               [],
               [],
               [
                 {
                   :call,
                   30,
                   {:remote, 30, {:atom, 30, Enum}, {:atom, 30, :map}},
                   [
                     {:call, 30, {:remote, 30, {:atom, 30, Foo}, {:atom, 30, :boo}}, []},
                     {
                       :fun,
                       30,
                       {
                         :clauses,
                         [
                           {
                             :clause,
                             30,
                             [{:var, 30, :_}],
                             [],
                             [
                               {
                                 :block,
                                 0,
                                 [
                                   {:call, 31,
                                    {:remote, 31, {:atom, 31, :baz}, {:atom, 31, :run}}, []},
                                   {:call, 32,
                                    {:remote, 32, {:atom, 32, XPBar.Foo}, {:atom, 32, :run}},
                                    [{:atom, 32, :baz}]}
                                 ]
                               }
                             ]
                           }
                         ]
                       }
                     }
                   ]
                 }
               ]
             }
           ]
  end
end
