defmodule Namespace.Path do
  def run(path, opts) when is_list(path) do
    path
    |> List.to_string()
    |> run(opts)
    |> String.to_charlist()
  end

  def run(path, opts) when is_binary(path) do
    apps = Keyword.fetch!(opts, :apps)

    path
    |> Path.split()
    |> Enum.map(fn path_component ->
      Enum.reduce(apps, path_component, fn app_name, path ->
        if path == Atom.to_string(app_name) do
          app_name
          |> Namespace.Module.run(opts)
          |> Atom.to_string()
        else
          path
        end
      end)
    end)
    |> Path.join()
  end
end
