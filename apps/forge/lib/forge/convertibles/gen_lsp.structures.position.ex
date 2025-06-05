defimpl Forge.Protocol.Convertible, for: GenLSP.Structures.Position do
  alias GenLSP.Structures.Position
  alias Forge.Protocol.Conversions

  def to_lsp(%Position{} = position) do
    Conversions.to_lsp(position)
  end

  def to_native(%Position{} = position, context_document) do
    Conversions.to_elixir(position, context_document)
  end
end
