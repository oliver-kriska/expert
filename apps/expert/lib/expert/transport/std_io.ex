defmodule Expert.Transport.StdIO do
  alias Forge.Protocol.Convert
  alias Forge.Protocol.JsonRpc

  require Logger

  @behaviour Expert.Transport

  def start_link(device, callback) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [{callback, device}])
    {:ok, pid}
  end

  def child_spec([device, callback]) do
    %{id: __MODULE__, start: {__MODULE__, :start_link, [device, callback]}}
  end

  def init({callback, device}) do
    :io.setopts(binary: true, encoding: :latin1)
    loop([], device, callback)
  end

  def write(io_device \\ :stdio, payload)

  def write(io_device, %_{} = payload) do
    with {:ok, lsp} <- encode(payload),
         {:ok, json} <- Jason.encode(lsp) do
      write(io_device, json)
    end
  end

  def write(io_device, %{} = payload) do
    with {:ok, encoded} <- Jason.encode(payload) do
      write(io_device, encoded)
    end
  end

  def write(io_device, payload) when is_binary(payload) do
    message =
      case io_device do
        device when device in [:stdio, :standard_io] or is_pid(device) ->
          {:ok, json_rpc} = JsonRpc.encode(payload)
          json_rpc

        _ ->
          payload
      end

    IO.binwrite(io_device, message)
  end

  def write(_, nil) do
  end

  def write(_, []) do
  end

  defp encode(%{id: id, result: result}) do
    with {:ok, result} <- dump_lsp(result) do
      {:ok,
       %{
         "jsonrpc" => "2.0",
         "id" => id,
         "result" => result
       }}
    end
  end

  defp encode(%{id: id, error: error}) do
    with {:ok, error} <- dump_lsp(error) do
      {:ok,
       %{
         "jsonrpc" => "2.0",
         "id" => id,
         "error" => error
       }}
    end
  end

  defp encode(%_{} = request) do
    dump_lsp(request)
  end

  defp dump_lsp(%module{} = item) do
    with {:ok, item} <- Convert.to_lsp(item) do
      Schematic.dump(module.schematic(), item)
    end
  end

  defp dump_lsp(list) when is_list(list) do
    dump =
      Enum.map(list, fn item ->
        case dump_lsp(item) do
          {:ok, dumped} -> dumped
          {:error, reason} -> throw({:error, reason})
        end
      end)

    {:ok, dump}
  catch
    {:error, reason} ->
      {:error, reason}
  end

  defp dump_lsp(other), do: {:ok, other}

  defp loop(buffer, device, callback) do
    case IO.binread(device, :line) do
      "\n" ->
        headers = parse_headers(buffer)

        with {:ok, content_length} <- content_length(headers),
             {:ok, data} <- read_body(device, content_length),
             {:ok, message} <- JsonRpc.decode(data) do
          callback.(message)
        else
          {:error, :empty_response} ->
            :noop

          {:error, reason} ->
            Logger.critical("read protocol message: #{inspect(reason)}")
        end

        loop([], device, callback)

      :eof ->
        Logger.critical("stdio received :eof, server will stop.")
        maybe_stop()

      line ->
        loop([line | buffer], device, callback)
    end
  end

  defp content_length(headers) do
    with {:ok, len_str} <- find_header(headers, "content-length") do
      parse_length(len_str)
    end
  end

  defp find_header(headers, name) do
    case List.keyfind(headers, name, 0) do
      {_, len_str} -> {:ok, len_str}
      nil -> {:error, {:header_not_found, name}}
    end
  end

  defp parse_length(len_str) when is_binary(len_str) do
    case Integer.parse(len_str) do
      {int, ""} -> {:ok, int}
      :error -> {:error, {:cant_parse_length, len_str}}
    end
  end

  defp read_body(device, byte_count) do
    case IO.binread(device, byte_count) do
      data when is_binary(data) ->
        {:ok, data}

      :eof ->
        Logger.critical("stdio received :eof, server will stop.")
        maybe_stop()

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_headers(headers) do
    Enum.map(headers, &parse_header/1)
  end

  defp parse_header(line) do
    [name, value] = String.split(line, ":")

    header_name =
      name
      |> String.downcase()
      |> String.trim()

    {header_name, String.trim(value)}
  end

  if Mix.env() == :test do
    defp maybe_stop do
      :ok
    end
  else
    defp maybe_stop do
      System.stop()
    end
  end
end
