defmodule Expert.Project.ProgressTest do
  alias Expert.Configuration
  alias Expert.Project
  alias Expert.Protocol.Notifications
  alias Expert.Protocol.Requests
  alias Expert.Test.DispatchFake
  alias Expert.Transport

  import Engine.Test.Fixtures
  import Engine.Api.Messages

  use ExUnit.Case
  use Patch
  use DispatchFake
  use Forge.Test.EventualAssertions

  setup do
    project = project()
    pid = start_supervised!({Project.Progress, project})
    DispatchFake.start()
    Engine.Dispatch.register_listener(pid, project_progress())
    Engine.Dispatch.register_listener(pid, percent_progress())

    {:ok, project: project}
  end

  def percent_begin(project, label, max) do
    message = percent_progress(stage: :begin, label: label, max: max)
    Engine.Api.broadcast(project, message)
  end

  defp percent_report(project, label, delta, message \\ nil) do
    message = percent_progress(stage: :report, label: label, message: message, delta: delta)
    Engine.Api.broadcast(project, message)
  end

  defp percent_complete(project, label, message) do
    message = percent_progress(stage: :complete, label: label, message: message)
    Engine.Api.broadcast(project, message)
  end

  def progress(stage, label, message \\ "") do
    project_progress(label: label, message: message, stage: stage)
  end

  def with_patched_transport(_) do
    test = self()

    patch(Transport, :write, fn message ->
      send(test, {:transport, message})
    end)

    :ok
  end

  def with_work_done_progress_support(_) do
    patch(Configuration, :client_supports?, fn :work_done_progress -> true end)
    :ok
  end

  describe "report the progress message" do
    setup [:with_patched_transport]

    test "it should be able to send the report progress", %{project: project} do
      patch(Configuration, :client_supports?, fn :work_done_progress -> true end)

      begin_message = progress(:begin, "mix compile")
      Engine.Api.broadcast(project, begin_message)

      assert_receive {:transport, %Requests.CreateWorkDoneProgress{lsp: %{token: token}}}
      assert_receive {:transport, %Notifications.Progress{}}

      report_message = progress(:report, "mix compile", "lib/file.ex")
      Engine.Api.broadcast(project, report_message)
      assert_receive {:transport, %Notifications.Progress{lsp: %{token: ^token, value: value}}}

      assert value.kind == "report"
      assert value.message == "lib/file.ex"
      assert value.percentage == nil
      assert value.cancellable == nil
    end

    test "it should write nothing when the client does not support work done", %{project: project} do
      patch(Configuration, :client_supports?, fn :work_done_progress -> false end)

      begin_message = progress(:begin, "mix compile")
      Engine.Api.broadcast(project, begin_message)

      refute_receive {:transport, %Requests.CreateWorkDoneProgress{lsp: %{}}}
    end
  end

  describe "reporting a percentage progress" do
    setup [:with_patched_transport, :with_work_done_progress_support]

    test "it should be able to increment the percentage", %{project: project} do
      percent_begin(project, "indexing", 400)

      assert_receive {:transport, %Requests.CreateWorkDoneProgress{lsp: %{token: token}}}
      assert_receive {:transport, %Notifications.Progress{} = progress}

      assert progress.lsp.value.kind == "begin"
      assert progress.lsp.value.title == "indexing"
      assert progress.lsp.value.percentage == 0

      percent_report(project, "indexing", 100)

      assert_receive {:transport, %Notifications.Progress{lsp: %{token: ^token, value: value}}}
      assert value.kind == "report"
      assert value.percentage == 25
      assert value.message == nil

      percent_report(project, "indexing", 260, "Almost done")

      assert_receive {:transport, %Notifications.Progress{lsp: %{token: ^token, value: value}}}
      assert value.percentage == 90
      assert value.message == "Almost done"

      percent_complete(project, "indexing", "Indexing Complete")

      assert_receive {:transport, %Notifications.Progress{lsp: %{token: ^token, value: value}}}
      assert value.kind == "end"
      assert value.message == "Indexing Complete"
    end

    test "it caps the percentage at 100", %{project: project} do
      percent_begin(project, "indexing", 100)
      percent_report(project, "indexing", 1000)
      assert_receive {:transport, %Notifications.Progress{lsp: %{value: %{kind: "begin"}}}}
      assert_receive {:transport, %Notifications.Progress{lsp: %{value: value}}}
      assert value.kind == "report"
      assert value.percentage == 100
    end

    test "it only allows the percentage to grow", %{project: project} do
      percent_begin(project, "indexing", 100)
      assert_receive {:transport, %Notifications.Progress{lsp: %{value: %{kind: "begin"}}}}

      percent_report(project, "indexing", 10)

      assert_receive {:transport, %Notifications.Progress{lsp: %{value: value}}}
      assert value.kind == "report"
      assert value.percentage == 10

      percent_report(project, "indexing", -10)
      assert_receive {:transport, %Notifications.Progress{lsp: %{value: value}}}
      assert value.kind == "report"
      assert value.percentage == 10

      percent_report(project, "indexing", 5)
      assert_receive {:transport, %Notifications.Progress{lsp: %{value: value}}}
      assert value.kind == "report"
      assert value.percentage == 15
    end
  end
end
