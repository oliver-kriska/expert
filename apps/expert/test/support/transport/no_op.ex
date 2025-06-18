defmodule Expert.Test.Transport.NoOp do
  @behaviour Expert.Transport

  def write(_message), do: :ok
end
