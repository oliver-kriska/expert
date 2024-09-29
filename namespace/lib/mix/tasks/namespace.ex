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
  alias Mix.Tasks.Namespace.Transform
  use Mix.Task

  @dev_deps [:namespace]

  # These app names and root modules are strings to avoid them being namespaced
  # by this task. Plugin discovery uses this task, which happens after
  # namespacing.
  @extra_apps %{
    "engine" => "Engine"
  }

  defp deps_apps() do
    Mix.Project.deps_apps()
    |> Kernel.--(@dev_deps)
    |> Enum.map(&to_string/1)
  end

  require Logger

  def run([base_directory]) do
    Process.put(:deps_apps, deps_apps())
    Transform.Apps.apply_to_all(base_directory)
    Transform.Beams.apply_to_all(base_directory)
    # consolidated

    # Transform.Beams.apply(base_directory)
    Transform.Scripts.apply_to_all(base_directory)
    # The boot file transform just turns script files into boot files
    # so it must come after the script file transform
    Transform.Boots.apply_to_all(base_directory)
    Transform.AppDirectories.apply_to_all(base_directory)
  end

  def app_names() do
    Map.keys(app_to_root_modules())
  end

  def root_modules() do
    app_to_root_modules()
    |> Map.values()
    |> List.flatten()
  end

  def app_to_root_modules() do
    case :persistent_term.get(__MODULE__, :not_loaded) do
      :not_loaded ->
        init()

      term ->
        term
    end
  end

  defp register_mappings(app_to_root_modules) do
    :persistent_term.put(__MODULE__, app_to_root_modules)
    app_to_root_modules
  end

  defp root_modules_for_apps(deps_apps) do
    deps_apps
    |> Enum.map(fn app_name ->
      all_modules = app_modules(app_name)

      case Enum.filter(all_modules, fn module -> length(safe_split_module(module)) == 1 end) do
        [] -> {app_name, [Expert]}
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

  defp extra_apps do
    Map.new(@extra_apps, fn {k, v} ->
      root_module =
        v
        |> List.wrap()
        |> Module.concat()

      {String.to_atom(k), [root_module]}
    end)
  end

  defp init() do
    Process.get(:deps_apps)
    |> Enum.map(&String.to_atom/1)
    |> root_modules_for_apps()
    |> Map.merge(extra_apps())
    |> register_mappings()
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
