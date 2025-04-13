defmodule Lexical.Identifier do
  @moduledoc """
  Returns the next globally unique identifier with an embedded timestamp and sequence ID.
  """

  import Bitwise

  @ts_size 42
  @seq_size 64 - @ts_size
  @seq_max 2 ** @seq_size - 1
  # First second of 2024 (milliseconds)
  @epoch 1_704_070_800_000

  @spec next_global!() :: integer
  def next_global!() do
    ts = System.os_time(:millisecond) - @epoch
    seq = rem(:erlang.unique_integer([:positive]), @seq_max)

    <<new_id::unsigned-integer-size(64)>> = <<
      ts::unsigned-integer-size(@ts_size),
      seq::unsigned-integer-size(@seq_size)
    >>

    new_id
  end

  def to_unix(id) when is_integer(id) do
    (id >>> @seq_size) + @epoch
  end

  def to_datetime(id) do
    id
    |> to_unix()
    |> DateTime.from_unix!(:millisecond)
  end

  def to_erl(id) do
    %DateTime{year: year, month: month, day: day, hour: hour, minute: minute, second: second} =
      to_datetime(id)

    {{year, month, day}, {hour, minute, second}}
  end
end
