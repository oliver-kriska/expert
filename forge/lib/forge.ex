defmodule Forge do
  @typedoc "A string representation of a uri"
  @type uri :: String.t()

  @typedoc "A string representation of a path on the filesystem"
  @type path :: String.t()

  alias Forge.Project

  def project_node? do
    !!:persistent_term.get({__MODULE__, :project}, false)
  end

  def get_project do
    :persistent_term.get({__MODULE__, :project}, nil)
  end

  def set_project(%Project{} = project) do
    :persistent_term.put({__MODULE__, :project}, project)
  end
end
