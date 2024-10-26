defmodule Namespace.AbstractTest do
  use ExUnit.Case, async: true

  setup do
    apps = [:foo, :bar, :baz]
    roots = [Foo, Bar, Engine]
    [apps: apps, roots: roots]
  end

  test "rewrite module", %{apps: apps, roots: roots} do
    {:ok, forms} =
      Namespace.Abstract.code_from(
        ~c"_build/test/lib/namespace/ebin/Elixir.Namespace.AbstractTest.Code.beam"
      )

    funcs =
      forms
      |> Namespace.Abstract.run(apps: apps, roots: roots)
      |> Enum.filter(fn x -> match?({:function, _, _, _, _}, x) end)
      |> Map.new(fn
        {:function, _, name, arity, body} -> {{name, arity}, body}
        _ -> nil
      end)

    assert funcs[{:run, 0}] == [
             {:clause, 6, [], [],
              [
                {:call, 7, {:atom, 7, :another}, []},
                {:call, 8, {:remote, 8, {:atom, 8, XPEngine}, {:atom, 8, :thing}}, []}
              ]}
           ]

    assert funcs[{:another, 0}] == [
             {:clause, 11, [], [],
              [
                {:call, 12, {:remote, 12, {:atom, 12, Enum}, {:atom, 12, :map}},
                 [
                   {:call, 12, {:remote, 12, {:atom, 12, XPFoo}, {:atom, 12, :boo}}, []},
                   {:fun, 12,
                    {:clauses,
                     [
                       {:clause, 12, [{:var, 12, :_}], [],
                        [
                          {:block, 0,
                           [
                             {:call, 13, {:remote, 13, {:atom, 13, :baz}, {:atom, 13, :run}}, []},
                             {:call, 14, {:remote, 14, {:atom, 14, XPBar.Foo}, {:atom, 14, :run}},
                              [{:atom, 14, :baz}]}
                           ]}
                        ]}
                     ]}}
                 ]}
              ]}
           ]
  end
end
