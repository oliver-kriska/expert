defmodule ExpertTest do
  alias Forge.Document
  alias Forge.Project

  import GenLSP.Test
  import Forge.Test.Fixtures

  use ExUnit.Case, async: false

  setup_all do
    start_supervised!({Document.Store, derive: [analysis: &Forge.Ast.analyze/1]})

    project_root = fixtures_path() |> Path.join("workspace_folders")

    main_project =
      project_root
      |> Path.join("main")
      |> Document.Path.to_uri()
      |> Project.new()

    secondary_project =
      project_root
      |> Path.join("secondary")
      |> Document.Path.to_uri()
      |> Project.new()

    [project_root: project_root, main_project: main_project, secondary_project: secondary_project]
  end

  setup do
    start_supervised!({Task.Supervisor, name: :expert_task_queue})
    start_supervised!({DynamicSupervisor, name: Expert.DynamicSupervisor})
    start_supervised!({DynamicSupervisor, Expert.Project.DynamicSupervisor.options()})
    start_supervised!({Expert.ActiveProjects, []})

    server =
      server(Expert,
        task_supervisor: :expert_task_queue,
        dynamic_supervisor: Expert.DynamicSupervisor
      )

    Process.link(server.lsp)

    client = client(server)

    [server: server, client: client]
  end

  def initialize_request(root_path, opts \\ []) do
    id = opts[:id] || 1
    projects = opts[:projects] || []

    %{
      method: "initialize",
      id: id,
      jsonrpc: "2.0",
      params: %{
        rootUri: Document.Path.to_uri(root_path),
        initializationOptions: %{},
        capabilities: %{
          workspace: %{
            workspaceFolders: true
          }
        },
        workspaceFolders:
          Enum.map(projects, fn project ->
            %{uri: project.root_uri, name: Project.name(project)}
          end)
      }
    }
  end

  def project_alive?(project) do
    project |> Expert.Project.Supervisor.name() |> Process.whereis() |> is_pid()
  end

  describe "initialize request" do
    test "starts a project at the initial workspace folders", %{
      client: client,
      project_root: project_root,
      main_project: main_project
    } do
      assert :ok =
               request(
                 client,
                 initialize_request(project_root, id: 1, projects: [main_project])
               )

      assert_result(1, %{
        "capabilities" => %{"workspace" => %{"workspaceFolders" => %{"supported" => true}}}
      })

      expected_message = "Started project node for #{Project.name(main_project)}"

      assert_notification(
        "window/logMessage",
        %{"message" => ^expected_message}
      )

      assert [project] = Expert.ActiveProjects.projects()
      assert project.root_uri == main_project.root_uri

      assert project_alive?(main_project)
    end
  end

  describe "workspace folders" do
    test "starts project nodes when adding workspace folders", %{
      client: client,
      project_root: project_root,
      main_project: main_project,
      secondary_project: secondary_project
    } do
      assert :ok =
               request(
                 client,
                 initialize_request(project_root, id: 1, projects: [main_project])
               )

      assert_result(1, _)

      expected_message = "Started project node for #{Project.name(main_project)}"

      assert_notification(
        "window/logMessage",
        %{"message" => ^expected_message}
      )

      assert [_project_1] = Expert.ActiveProjects.projects()

      assert :ok =
               notify(
                 client,
                 %{
                   method: "workspace/didChangeWorkspaceFolders",
                   jsonrpc: "2.0",
                   params: %{
                     event: %{
                       added: [
                         %{uri: secondary_project.root_uri, name: secondary_project.root_uri}
                       ],
                       removed: []
                     }
                   }
                 }
               )

      expected_message = "Started project node for #{Project.name(secondary_project)}"

      assert_notification(
        "window/logMessage",
        %{"message" => ^expected_message}
      )

      assert [project_1, project_2] = Expert.ActiveProjects.projects()
      assert project_1.root_uri == main_project.root_uri
      assert project_alive?(main_project)

      assert project_2.root_uri == secondary_project.root_uri
      assert project_alive?(secondary_project)
    end

    test "can remove workspace folders", %{
      client: client,
      project_root: project_root,
      main_project: main_project
    } do
      assert :ok =
               request(
                 client,
                 initialize_request(project_root, id: 1, projects: [main_project])
               )

      assert_result(1, _)
      expected_message = "Started project node for #{Project.name(main_project)}"

      assert_notification(
        "window/logMessage",
        %{"message" => ^expected_message}
      )

      assert [project] = Expert.ActiveProjects.projects()
      assert project.root_uri == main_project.root_uri
      assert project_alive?(main_project)

      assert :ok =
               notify(
                 client,
                 %{
                   method: "workspace/didChangeWorkspaceFolders",
                   jsonrpc: "2.0",
                   params: %{
                     event: %{
                       added: [],
                       removed: [
                         %{uri: main_project.root_uri, name: main_project.root_uri}
                       ]
                     }
                   }
                 }
               )

      expected_message = "Stopping project node for #{Project.name(main_project)}"

      assert_notification(
        "window/logMessage",
        %{"message" => ^expected_message}
      )

      assert [] = Expert.ActiveProjects.projects()
      refute project_alive?(main_project)
    end
  end

  describe "opening files" do
    test "starts a project node when opening a file in a folder not specified as workspace folder",
         %{
           client: client,
           project_root: project_root,
           main_project: main_project,
           secondary_project: secondary_project
         } do
      assert :ok =
               request(
                 client,
                 initialize_request(project_root, id: 1, projects: [main_project])
               )

      expected_message = "Started project node for #{Project.name(main_project)}"

      assert_notification(
        "window/logMessage",
        %{"message" => ^expected_message}
      )

      file_uri = Path.join([secondary_project.root_uri, "lib", "secondary.ex"])

      assert :ok =
               notify(
                 client,
                 %{
                   method: "textDocument/didOpen",
                   jsonrpc: "2.0",
                   params: %{
                     textDocument: %{
                       uri: file_uri,
                       languageId: "elixir",
                       version: 1,
                       text: ""
                     }
                   }
                 }
               )

      expected_message = "Started project node for #{Project.name(secondary_project)}"

      assert_notification(
        "window/logMessage",
        %{"message" => ^expected_message}
      )

      assert [_main, project] = Expert.ActiveProjects.projects()
      assert project.root_uri == secondary_project.root_uri
      assert project_alive?(project)
    end
  end
end
