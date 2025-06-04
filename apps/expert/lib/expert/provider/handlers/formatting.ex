defmodule Expert.Provider.Handlers.Formatting do
  alias Expert.Configuration
  alias Expert.Protocol.Response
  alias Forge.Document.Changes
  alias GenLSP.Requests
  alias GenLSP.Structures

  require Logger

  def handle(
        %Requests.TextDocumentFormatting{params: %Structures.DocumentFormattingParams{} = params} =
          request,
        %Configuration{} = config
      ) do
    document = Lexical.Document.Container.context_document(params, nil)

    case Engine.Api.format(config.project, document) do
      {:ok, %Changes{} = document_edits} ->
        response = %Response{id: request.id, result: document_edits}
        {:reply, response}

      {:error, reason} ->
        Logger.error("Formatter failed #{inspect(reason)}")
        {:reply, %Response{id: request.id, result: nil}}
    end
  end
end
