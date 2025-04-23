defimpl Forge.Document.Container, for: Forge.Document.Location do
  alias Forge.Document
  alias Forge.Document.Location

  def context_document(%Location{document: %Document{} = context_document}, _) do
    context_document
  end

  def context_document(%Location{uri: uri}, context_document) when is_binary(uri) do
    case Document.Store.fetch(uri) do
      {:ok, %Document{} = document} ->
        document

      _ ->
        context_document
    end
  end
end
