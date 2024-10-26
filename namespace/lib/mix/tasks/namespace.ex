defmodule Mix.Tasks.Namespace do
  @moduledoc """
  This task is used after a release is assembled, and investigates the remote_control
  app for its dependencies, at which point it applies transformers to various parts of the
  app.

  Transformers take a path, find their relevant files and apply transforms to them. For example,
  the Beams transformer will find any instances of modules in .beam files, and will apply namepaces
  to them if the module is one of the modules defined in a dependency.

  This task takes a single argument, which is the full path to the release.
  """
  use Mix.Task

  require Logger

  def run(argv) do
    {options, _rest} =
      OptionParser.parse!(argv,
        strict: [
          directory: :string,
          dot_apps: :boolean,
          include_app: :keep,
          include_root: :keep,
          exclude_app: :keep,
          exclude_root: :keep
        ]
      )

    base_directory = Keyword.fetch!(options, :directory)

    include_apps = Keyword.get_values(options, :include_app) |> Enum.map(&String.to_atom/1)
    include_roots = Keyword.get_values(options, :include_root) |> Enum.map(&Module.concat([&1]))
    exclude_apps = Keyword.get_values(options, :exclude_app) |> Enum.map(&String.to_atom/1)
    exclude_roots = Keyword.get_values(options, :exclude_root) |> Enum.map(&Module.concat([&1]))

    apps = Enum.uniq(Mix.Project.deps_apps() ++ include_apps) -- exclude_apps

    roots_from_apps =
      apps |> root_modules_for_apps() |> Map.values() |> List.flatten() |> Enum.uniq()

    roots = (roots_from_apps ++ include_roots) -- exclude_roots

    opts = [apps: apps, roots: roots, do_apps: options[:apps]]

    Namespace.Transform.Apps.run_all(base_directory, opts)

    Namespace.Transform.Beams.run_all(base_directory, opts)

    if options[:apps] do
      Namespace.Transform.AppDirectories.run_all(base_directory, opts)
    end
  end

  defp root_modules_for_apps(deps_apps) do
    deps_apps
    |> Enum.map(fn app_name ->
      all_modules = app_modules(app_name)

      case Enum.filter(all_modules, fn module -> length(safe_split_module(module)) == 1 end) do
        [] -> {app_name, []}
        root_modules -> {app_name, root_modules}
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Map.new()
  end

  defp app_modules(dep_app) do
    Application.ensure_loaded(dep_app)

    case :application.get_key(dep_app, :modules) do
      {:ok, modules} ->
        modules

      _ ->
        [Expert]
    end
  end

  defp safe_split_module(module) do
    case safe_split(module) do
      {:elixir, segments} -> segments
      {:erlang, _} -> []
    end
  end

  def safe_split(module, opts \\ [])

  def safe_split(module, opts) when is_atom(module) do
    string_name = Atom.to_string(module)

    {type, split_module} =
      case String.split(string_name, ".") do
        ["Elixir" | rest] ->
          {:elixir, rest}

        [_erlang_module] = module ->
          {:erlang, module}
      end

    split_module =
      case Keyword.get(opts, :as, :binaries) do
        :binaries ->
          split_module

        :atoms ->
          Enum.map(split_module, &String.to_atom/1)
      end

    {type, split_module}
  end
end
