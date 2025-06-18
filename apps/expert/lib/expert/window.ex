defmodule Expert.Window do
  alias Expert.Transport
  alias Forge.Protocol.Id
  alias GenLSP.Enumerations
  alias GenLSP.Notifications
  alias GenLSP.Requests
  alias GenLSP.Structures

  @type level :: :error | :warning | :info | :log
  @type message_result :: {:errory, term()} | {:ok, nil} | {:ok, Structures.MessageActionItem.t()}
  @type on_response_callback :: (message_result() -> any())
  @type message :: String.t()
  @type action :: String.t()

  @levels [:error, :warning, :info, :log]

  @spec log(level, message()) :: :ok
  def log(level, message) when level in @levels and is_binary(message) do
    log_message = log_message(level, message)
    Transport.write(log_message)
    :ok
  end

  for level <- [:error, :warning, :info] do
    def unquote(level)(message) do
      log(unquote(level), message)
    end
  end

  # There is a warning introduced somehow in #19 but this file will get removed
  # in #20 so we can ignore it for now.
  @dialyzer {:nowarn_function, show: 2}

  @spec show(level(), message()) :: :ok
  def show(level, message) when level in @levels and is_binary(message) do
    show_message = show_message(level, message)
    Transport.write(show_message)
    :ok
  end

  for type <- @levels do
    def log_message(unquote(type), message) when is_binary(message) do
      %Notifications.WindowLogMessage{
        params: %Structures.ShowMessageParams{
          message: message,
          type: Enumerations.MessageType.unquote(type)
        }
      }
    end

    def show_message(unquote(type), message) when is_binary(message) do
      %Notifications.WindowShowMessage{
        params: %Structures.ShowMessageParams{
          message: message,
          type: Enumerations.MessageType.unquote(type)
        }
      }
    end
  end

  @spec show_message(level(), message()) :: :ok
  def show_message(level, message) do
    request = %Requests.WindowShowMessageRequest{
      id: Id.next(),
      params: %Structures.ShowMessageRequestParams{message: message, type: level}
    }

    Expert.server_request(request)
  end

  for level <- @levels,
      fn_name = :"show_#{level}_message" do
    def unquote(fn_name)(message) do
      show_message(unquote(level), message)
    end
  end

  for level <- @levels,
      fn_name = :"show_#{level}_message" do
    @doc """
    Shows a message at the #{level} level. Delegates to `show_message/4`
    """
    def unquote(fn_name)(message, actions, on_response) when is_function(on_response, 1) do
      show_message(unquote(level), message, actions, on_response)
    end
  end

  @doc """
  Shows a message request and handles the response

  Displays a message to the user in the UI and waits for a response.
  The result type handed to the callback function is a
  `GenLSP.Structures.MessageActionItem` or nil if there was no response
  from the user.

  The strings passed in as the `actions` command are displayed to the user, and when
  they select one, the `Types.Message.ActionItem` is passed to the callback function.
  """
  @spec show_message(level(), message(), [action()], on_response_callback) :: :ok
  def show_message(level, message, actions, on_response)
      when is_function(on_response, 1) do
    action_items =
      Enum.map(actions, fn action_string ->
        %Structures.MessageActionItem{title: action_string}
      end)

    request =
      %Requests.WindowShowMessageRequest{
        id: Id.next(),
        params: %Structures.ShowMessageRequestParams{
          message: message,
          actions: action_items,
          type: level
        }
      }

    Expert.server_request(request, fn _request, response -> on_response.(response) end)
  end
end
