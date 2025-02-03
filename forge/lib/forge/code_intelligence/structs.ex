defmodule Forge.CodeIntelligence.Structs do
  alias Forge.Module.Loader
  alias Forge.Search.Indexer.Entry
  alias Forge.Search.Store

  def for_project do
    if Mix.Project.get() do
      {:ok, structs_from_index()}
    else
      Forge.Mix.in_project(fn _ -> structs_from_index() end)
    end
  end

  defp structs_from_index do
    case Store.exact(type: :struct, subtype: :definition) do
      {:ok, entries} ->
        for %Entry{subject: struct_module} <- entries,
            Loader.ensure_loaded?(struct_module) do
          struct_module
        end

      _ ->
        []
    end
  end
end
