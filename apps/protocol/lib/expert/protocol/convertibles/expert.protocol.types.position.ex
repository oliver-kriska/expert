defimpl Forge.Convertible, for: Expert.Protocol.Types.Position do
  alias Expert.Protocol.Conversions
  alias Expert.Protocol.Types

  def to_lsp(%Types.Position{} = position) do
    Conversions.to_lsp(position)
  end

  def to_native(%Types.Position{} = position, context_document) do
    Conversions.to_elixir(position, context_document)
  end
end
