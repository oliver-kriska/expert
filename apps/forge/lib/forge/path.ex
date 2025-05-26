defmodule Forge.Path do
  @moduledoc """
  Helpers for working with paths.
  """

  @doc """
  Checks if the `parent_path` is a parent directory of the `child_path`.

  This function normalizes both paths and compares their segments to determine
  if the `parent_path` is a prefix of the `child_path`.

  ## Examples

      iex> Forge.Path.parent_path?("/home/user/docs/file.txt", "/home/user")
      true

      iex> Forge.Path.parent_path?("/home/user/docs/file.txt", "/home/admin")
      false

      iex> Forge.Path.parent_path?("/home/user/docs", "/home/user/docs")
      true

      iex> Forge.Path.parent_path?("/home/user/docs", "/home/user/docs/subdir")
      false
  """
  def parent_path?(child_path, parent_path) do
    normalized_child = Path.expand(child_path)
    normalized_parent = Path.expand(parent_path)

    child_segments = Path.split(normalized_child)
    parent_segments = Path.split(normalized_parent)

    Enum.take(child_segments, length(parent_segments)) == parent_segments
  end
end
