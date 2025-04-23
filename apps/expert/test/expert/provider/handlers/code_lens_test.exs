defmodule Expert.Provider.Handlers.CodeLensTest do
  alias Forge.Document
  alias Forge.Project
  alias Expert.Proto.Convert
  alias Expert.Protocol.Requests.CodeLens
  alias Expert.Protocol.Types
  alias Engine
  alias Expert
  alias Expert.Provider.Handlers

  import Expert.Test.Protocol.Fixtures.LspProtocol
  import Engine.Api.Messages
  import Engine.Test.Fixtures
  import Forge.Test.RangeSupport

  use ExUnit.Case, async: false
  use Patch

  setup_all do
    start_supervised(Document.Store)
    project = project(:umbrella)

    start_supervised!({DynamicSupervisor, Expert.Project.Supervisor.options()})
    start_supervised!({Expert.Project.Supervisor, project})

    Engine.Api.register_listener(project, self(), [project_compiled()])
    Engine.Api.schedule_compile(project, true)

    assert_receive project_compiled(), 5000

    {:ok, project: project}
  end

  defp with_indexing_enabled(_) do
    patch(Engine.Api, :index_running?, false)
    :ok
  end

  defp with_mix_exs(%{project: project}) do
    path = Project.mix_exs_path(project)
    %{uri: Document.Path.ensure_uri(path)}
  end

  def build_request(path) do
    uri = Document.Path.ensure_uri(path)

    params = [
      text_document: [uri: uri]
    ]

    with {:ok, _} <- Document.Store.open_temporary(uri),
         {:ok, req} <- build(CodeLens, params) do
      Convert.to_native(req)
    end
  end

  def handle(request, project) do
    config = Expert.Configuration.new(project: project)
    Handlers.CodeLens.handle(request, config)
  end

  describe "code lens for mix.exs" do
    setup [:with_mix_exs, :with_indexing_enabled]

    test "emits a code lens at the project definition", %{project: project, uri: referenced_uri} do
      mix_exs_path = Document.Path.ensure_path(referenced_uri)
      mix_exs = File.read!(mix_exs_path)

      {:ok, request} = build_request(mix_exs_path)
      {:reply, %{result: lenses}} = handle(request, project)

      assert [%Types.CodeLens{} = code_lens] = lenses

      assert extract(mix_exs, code_lens.range) =~ "def project"
      assert code_lens.command == Handlers.Commands.reindex_command(project)
    end

    test "does not emit a code lens for a project file", %{project: project} do
      {:ok, request} =
        project
        |> Project.project_path()
        |> Path.join("apps/first/lib/umbrella/first.ex")
        |> build_request()

      assert {:reply, %{result: []}} = handle(request, project)
    end

    test "does not emite a code lens for an umbrella app's mix.exs", %{project: project} do
      {:ok, request} =
        project
        |> Project.project_path()
        |> Path.join("apps/first/mix.exs")
        |> build_request()

      assert {:reply, %{result: []}} = handle(request, project)
    end
  end
end
