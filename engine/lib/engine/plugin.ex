defmodule Engine.Plugin do
  alias Engine.Document
  alias Engine.Project

  alias Engine.Api.Messages
  alias Engine.Plugin.Runner

  import Messages

  def diagnose(%Project{} = project, build_number) do
    on_complete = fn
      [] ->
        :ok

      [_ | _] = diagnostics ->
        message =
          project_diagnostics(
            project: project,
            build_number: build_number,
            diagnostics: diagnostics
          )

        Engine.broadcast(message)
    end

    Runner.diagnose(project, on_complete)
  end

  def diagnose(%Project{} = project, build_number, %Document{} = document) do
    on_complete = fn
      [] ->
        :ok

      [_ | _] = diagnostics ->
        message =
          file_diagnostics(
            project: project,
            build_number: build_number,
            uri: document.uri,
            diagnostics: diagnostics
          )

        Engine.broadcast(message)
    end

    Runner.diagnose(document, on_complete)
  end
end
