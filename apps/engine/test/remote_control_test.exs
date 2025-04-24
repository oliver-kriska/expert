defmodule EngineTest do
  alias Forge.Document
  alias Forge.Project

  use ExUnit.Case
  use Forge.Test.EventualAssertions
  import Engine.Test.Fixtures

  def start_project(%Project{} = project) do
    start_supervised!({Engine.ProjectNodeSupervisor, project})
    assert {:ok, _, _} = Engine.start_link(project)
    :ok
  end

  def engine_cwd(project) do
    Engine.call(project, File, :cwd!, [])
  end

  describe "detecting an umbrella app" do
    test "it changes the directory to the root if it's started in a subapp" do
      parent_project = project(:umbrella)

      subapp_project =
        [fixtures_path(), "umbrella", "apps", "first"]
        |> Path.join()
        |> Document.Path.to_uri()
        |> Project.new()

      start_project(subapp_project)

      assert_eventually engine_cwd(subapp_project) == Project.root_path(parent_project),
                        250
    end

    test "keeps the current directory if it's started in the parent app" do
      parent_project = project(:umbrella)
      start_project(parent_project)

      assert_eventually engine_cwd(parent_project) == Project.root_path(parent_project),
                        250
    end
  end
end
