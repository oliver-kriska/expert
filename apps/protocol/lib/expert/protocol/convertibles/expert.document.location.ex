defimpl Forge.Convertible, for: Forge.Document.Location do
  alias Expert.Protocol.Conversions
  alias Expert.Protocol.Types
  alias Forge.Document

  def to_lsp(%Document.Location{} = location) do
    with {:ok, range} <- Conversions.to_lsp(location.range) do
      uri = Document.Location.uri(location)
      {:ok, Types.Location.new(uri: uri, range: range)}
    end
  end

  def to_native(%Document.Location{} = location, _context_document) do
    {:ok, location}
  end
end
