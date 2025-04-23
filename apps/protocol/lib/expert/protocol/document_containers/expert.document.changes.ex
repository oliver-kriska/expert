defimpl Forge.Document.Container, for: Forge.Document.Changes do
  alias Forge.Document

  def context_document(%Document.Changes{} = edits, prior_context_document) do
    edits.document || prior_context_document
  end
end
