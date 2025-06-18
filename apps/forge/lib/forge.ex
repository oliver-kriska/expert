defmodule Forge do
  @moduledoc """
  Common data structures and utilities for the Expert Language Server.

  If you're building a plugin, You're probably going to want to look at the documentation
  for core data structures like

  `Forge.Project` - The Expert project structure

  `Forge.Document` - A text document, given to you by the language server

  `Forge.Document.Position` - A position inside a document

  `Forge.Document.Range` - A range of text inside a document
  """
  @typedoc "A string representation of a uri"
  @type uri :: String.t()

  @typedoc "A string representation of a path on the filesystem"
  @type path :: String.t()
end
