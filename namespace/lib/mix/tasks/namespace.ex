defmodule Mix.Tasks.Namespace do
  @moduledoc """
  This task will apply namespacing to a set of .beam and .app files in the given directory.

  Primarily works on a list of application and a list of "module roots".

  A module root is the first segment of an Elixir module, e.g., "Foo" in "Foo.Bar.Baz".

  The initial list of apps and roots (before additional inclusions and exclusions) are derived from
  fetching the projects deps via `Mix.Project.deps_apps/0`. From there, each dependency's modules are
  fetched via `:application.get_key(dep_app, :modules)`.

  ## Options

  * `--directory` - The active working directory (required)
  * `--[no-]dot-apps` - Whether to namespace application names and .app files at all. Useful to disable if you dont need to start the project like a normal application. Defaults to false.
  * `--include-app` - Adds the given application to the list of applications to namespace. 
  * `--exclude-app` - Removes the given application from the list of applications to namespace. 
  * `--include-root` - Adds the given module "root" to the list of "roots" to namespace. 
  * `--exclude-root` - Removes the given module "root" from the list of "roots" to namespace. 


  ## Usage

  ```bash
  mix namespace --directory _build/prod --include-app engine --include-root Engine --exclude-app namespace --dot-apps
  mix namespace --directory _build/dev --include-app expert --exclude-root Expert --exclude-app burrito --exclude-app namespace --exclude-root Jason --include-root Engine
  ```
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

    opts = [apps: apps, roots: roots, do_apps: options[:dot_apps]]

    Namespace.Transform.Apps.run_all(base_directory, opts)

    Namespace.Transform.Beams.run_all(base_directory, opts)

    if options[:dot_apps] do
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
