defimpl Forge.Convertible, for: Expert.Protocol.Types.Location do
  alias Expert.Protocol.Conversions
  alias Expert.Protocol.Types
  alias Forge.Document.Container
  alias Forge.Document

  def to_lsp(%Types.Location{} = location) do
    with {:ok, range} <- Conversions.to_lsp(location.range) do
      {:ok, %Types.Location{location | range: range}}
    end
  end

  def to_native(%Types.Location{} = location, context_document) do
    context_document = Container.context_document(location, context_document)

    with {:ok, range} <- Conversions.to_elixir(location.range, context_document) do
      {:ok, Document.Location.new(range, context_document.uri)}
    end
  end
end
