defmodule Expert.Provider.Handlers.Formatting do
  alias Expert.Configuration
  alias Expert.Protocol.Requests
  alias Expert.Protocol.Responses
  alias Forge.Document.Changes

  require Logger

  def handle(%Requests.Formatting{} = request, %Configuration{} = config) do
    document = request.document

    case Engine.Api.format(config.project, document) do
      {:ok, %Changes{} = document_edits} ->
        response = Responses.Formatting.new(request.id, document_edits)
        Logger.info("Response #{inspect(response)}")
        {:reply, response}

      {:error, reason} ->
        Logger.error("Formatter failed #{inspect(reason)}")
        {:reply, Responses.Formatting.new(request.id, nil)}
    end
  end
end
