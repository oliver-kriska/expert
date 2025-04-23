defmodule Mix.Tasks.Namespace.Transform.AppDirectories do
  alias Mix.Tasks.Namespace

  def apply_to_all(base_directory) do
    base_directory
    |> find_app_directories()
    |> Enum.each(&apply_transform(base_directory, &1))
  end

  def apply_transform(base_dirctory, app_path) do
    namespaced_relative_path =
      app_path
      |> Path.relative_to(base_dirctory)
      |> Namespace.Path.apply()

    namespaced_app_path = Path.join(base_dirctory, namespaced_relative_path)

    with {:ok, _} <- File.rm_rf(namespaced_app_path) do
      File.rename!(app_path, namespaced_app_path)
    end
  end

  defp find_app_directories(base_directory) do
    app_globs = Enum.join(Namespace.app_names(), "*,")

    [base_directory, "lib", "{" <> app_globs <> "*}"]
    |> Path.join()
    |> Path.wildcard()
  end
end
