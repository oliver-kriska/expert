defimpl Forge.Document.Container, for: Expert.Protocol.Notifications.PublishDiagnostics do
  alias Expert.Protocol.Notifications.PublishDiagnostics
  alias Forge.Document
  require Logger

  def context_document(%PublishDiagnostics{uri: uri} = publish, context_document)
      when is_binary(uri) do
    case Document.Store.open_temporary(publish.uri) do
      {:ok, source_doc} ->
        source_doc

      error ->
        Logger.error("Failed to open #{uri} temporarily because #{inspect(error)}")
        context_document
    end
  end

  def context_document(_, context_doc) do
    context_doc
  end
end
