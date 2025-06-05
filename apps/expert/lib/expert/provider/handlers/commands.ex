defmodule Expert.Provider.Handlers.Commands do
  alias Expert.Configuration
  alias Forge.Protocol.Response
  alias Forge.Protocol.ErrorResponse
  alias Expert.Window
  alias Forge.Project
  alias GenLSP.Enumerations.ErrorCodes
  alias GenLSP.Requests
  alias GenLSP.Structures

  require Logger

  @reindex_name "Reindex"

  def names do
    [@reindex_name]
  end

  def reindex_command(%Project{} = project) do
    project_name = Project.name(project)

    %Structures.Command{
      title: "Rebuild #{project_name}'s code search index",
      command: @reindex_name
    }
  end

  def handle(
        %Requests.WorkspaceExecuteCommand{params: %Structures.ExecuteCommandParams{} = params} =
          request,
        %Configuration{} = config
      ) do
    response =
      case params.command do
        @reindex_name ->
          Logger.info("Reindex #{Project.name(config.project)}")
          reindex(config.project, request.id)

        invalid ->
          message = "#{invalid} is not a valid command"
          internal_error(request.id, message)
      end

    {:reply, response}
  end

  defp reindex(%Project{} = project, request_id) do
    case Engine.Api.reindex(project) do
      :ok ->
        %Response{id: request_id, result: "ok"}

      error ->
        Window.show_error_message("Indexing #{Project.name(project)} failed")
        Logger.error("Indexing command failed due to #{inspect(error)}")

        internal_error(request_id, "Could not reindex: #{error}")
    end
  end

  defp internal_error(request_id, message) do
    %ErrorResponse{
      id: request_id,
      error: %GenLSP.ErrorResponse{code: ErrorCodes.internal_error(), message: message}
    }
  end
end
