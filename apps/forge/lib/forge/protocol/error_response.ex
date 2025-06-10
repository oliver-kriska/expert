defmodule Forge.Protocol.ErrorResponse do
  import Schematic

  alias GenLSP.ErrorResponse

  @type t :: %__MODULE__{
          id: integer(),
          error: ErrorResponse.t(),
          jsonrpc: String.t()
        }

  defstruct [:id, :error, jsonrpc: "2.0"]

  def schematic do
    schema(__MODULE__, %{
      id: int(),
      error: ErrorResponse.schematic(),
      jsonrpc: "2.0"
    })
  end
end
