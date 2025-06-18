defmodule Expert.Transport do
  @moduledoc """
  A behaviour for a LSP transport
  """
  @callback write(Jason.Encoder.t()) :: Jason.Encoder.t()

  alias Expert.Transport.StdIO

  @implementation Application.compile_env(:expert, :transport, StdIO)

  defdelegate write(message), to: @implementation
end
