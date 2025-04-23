defmodule Expert.Provider.Handlers.GoToDefinition do
  alias Expert.Protocol.Requests.GoToDefinition
  alias Expert.Protocol.Responses
  alias Engine
  alias Expert.Configuration

  require Logger

  def handle(%GoToDefinition{} = request, %Configuration{} = config) do
    case Engine.Api.definition(config.project, request.document, request.position) do
      {:ok, native_location} ->
        {:reply, Responses.GoToDefinition.new(request.id, native_location)}

      {:error, reason} ->
        Logger.error("GoToDefinition failed: #{inspect(reason)}")
        {:reply, Responses.GoToDefinition.new(request.id, nil)}
    end
  end
end
