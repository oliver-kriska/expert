defmodule Forge.Protocol.Response do
  import Schematic

  defstruct [:id, :result, jsonrpc: "2.0"]

  @type t() :: %__MODULE__{
          id: integer(),
          result: any(),
          jsonrpc: String.t()
        }

  def schematic() do
    schema(__MODULE__, %{
      id: int(),
      result: any(),
      jsonrpc: "2.0"
    })
  end
end
