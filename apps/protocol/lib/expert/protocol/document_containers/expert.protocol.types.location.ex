defimpl Forge.Document.Container, for: Expert.Protocol.Types.Location do
  alias Expert.Protocol.Types
  alias Forge.Document

  def context_document(%Types.Location{} = location, parent_document) do
    case Document.Store.fetch(location.uri) do
      {:ok, doc} -> doc
      _ -> parent_document
    end
  end
end
