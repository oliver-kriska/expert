defmodule Mix.Dialyzer do
  def dependency do
    {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false, optional: true}
  end

  def config(opts \\ []) do
    add_apps = [:compiler, :ex_unit, :mix, :wx | Keyword.get(opts, :add_apps, [])]

    [
      plt_core_path: absolute_path("priv/plts"),
      plt_file: {:no_warn, absolute_path("priv/plts/#{plt_name()}.plt")},
      plt_add_deps: :apps_direct,
      plt_add_apps: add_apps,
      ignore_warnings: absolute_path("dialyzer.ignore-warnings")
    ]
  end

  def absolute_path(relative_path) do
    __ENV__.file
    |> Path.dirname()
    |> Path.join(relative_path)
  end

  defp plt_name do
    File.cwd!() |> Path.basename() |> String.to_atom()
  end
end
