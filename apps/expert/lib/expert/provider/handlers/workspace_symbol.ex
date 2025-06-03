defmodule Expert.Provider.Handlers.WorkspaceSymbol do
  alias Engine.Api
  alias Engine.CodeIntelligence.Symbols
  alias Expert.Configuration
  alias Expert.Protocol.Response
  alias GenLSP.Requests
  alias GenLSP.Structures

  require SymbolKind

  require Logger

  def handle(
        %Requests.WorkspaceSymbol{params: %Structures.WorkspaceSymbolParams{} = params} = request,
        %Configuration{} = config
      ) do
    symbols =
      if String.length(params.query) > 1 do
        config.project
        |> Api.workspace_symbols(params.query)
        |> tap(fn symbols -> Logger.info("syms #{inspect(Enum.take(symbols, 5))}") end)
        |> Enum.map(&to_response/1)
      else
        []
      end

    response = %Response{id: request.id, result: symbols}
    {:reply, response}
  end

  def to_response(%Symbols.Workspace{} = root) do
    %Structures.WorkspaceSymbol{
      kind: to_kind(root.type),
      location: to_location(root.link),
      name: root.name,
      container_name: root.container_name
    }
  end

  defp to_location(%Symbols.Workspace.Link{} = link) do
    %Structures.Location{uri: link.uri, range: link.detail_range}
  end

  defp to_kind(:struct), do: :struct
  defp to_kind(:module), do: :module
  defp to_kind({:protocol, _}), do: :module
  defp to_kind({:xp_protocol, _}), do: :module
  defp to_kind(:variable), do: :variable
  defp to_kind({:function, _}), do: :function
  defp to_kind(:module_attribute), do: :constant
  defp to_kind(:ex_unit_test), do: :method
  defp to_kind(:ex_unit_describe), do: :method
  defp to_kind(:ex_unit_setup), do: :method
  defp to_kind(:ex_unit_setup_all), do: :method
  defp to_kind(:type), do: :type_parameter
  defp to_kind(:spec), do: :interface
  defp to_kind(:file), do: :file
end
