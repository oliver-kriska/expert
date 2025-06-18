defmodule Expert.Project.Progress.Percentage do
  @moduledoc """
  The backing data structure for percentage based progress reports
  """
  alias Forge.Math
  alias GenLSP.Notifications
  alias GenLSP.Structures

  @enforce_keys [:token, :kind, :max]
  defstruct [:token, :kind, :title, :message, :max, current: 0]

  def begin(title, max) do
    token = System.unique_integer([:positive])
    %__MODULE__{token: token, kind: :begin, title: title, max: max}
  end

  def report(percentage, delta, message \\ "")

  def report(%__MODULE__{} = percentage, delta, message) when is_integer(delta) and delta >= 0 do
    new_current = percentage.current + delta

    %__MODULE__{percentage | kind: :report, message: message, current: new_current}
  end

  def report(%__MODULE__{} = percentage, delta, _message) when is_integer(delta) do
    percentage
  end

  def report(_, _, _) do
    nil
  end

  def complete(%__MODULE__{} = percentage, message) do
    %__MODULE__{percentage | kind: :end, current: percentage.max, message: message}
  end

  def to_protocol(%__MODULE__{kind: :begin} = value) do
    %Notifications.DollarProgress{
      params: %Structures.ProgressParams{
        token: value.token,
        value: %Structures.WorkDoneProgressBegin{kind: "begin", title: value.title, percentage: 0}
      }
    }
  end

  def to_protocol(%__MODULE__{kind: :report} = value) do
    percent_complete =
      (value.current / value.max * 100)
      |> round()
      |> Math.clamp(0, 100)

    %Notifications.DollarProgress{
      params: %Structures.ProgressParams{
        token: value.token,
        value: %Structures.WorkDoneProgressReport{
          kind: "report",
          message: value.message,
          percentage: percent_complete
        }
      }
    }
  end

  def to_protocol(%__MODULE__{kind: :end} = value) do
    %Notifications.DollarProgress{
      params: %Structures.ProgressParams{
        token: value.token,
        value: %Structures.WorkDoneProgressEnd{kind: "end", message: value.message}
      }
    }
  end
end
