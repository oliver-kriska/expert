defmodule Expert.Project.Progress.Value do
  alias GenLSP.Notifications
  alias GenLSP.Structures

  @enforce_keys [:token, :kind]
  defstruct [:token, :kind, :title, :message]

  def begin(title) do
    token = System.unique_integer([:positive])
    %__MODULE__{token: token, kind: :begin, title: title}
  end

  def report(%__MODULE__{token: token}, message) do
    %__MODULE__{token: token, kind: :report, message: message}
  end

  def report(_, _) do
    nil
  end

  def complete(%__MODULE__{token: token}, message) do
    %__MODULE__{token: token, kind: :end, message: message}
  end

  def to_protocol(%__MODULE__{kind: :begin} = value) do
    %Notifications.DollarProgress{
      params: %Structures.ProgressParams{
        token: value.token,
        value: %Structures.WorkDoneProgressBegin{kind: "begin", title: value.title}
      }
    }
  end

  def to_protocol(%__MODULE__{kind: :report} = value) do
    %Notifications.DollarProgress{
      params: %Structures.ProgressParams{
        token: value.token,
        value: %Structures.WorkDoneProgressReport{kind: "report", message: value.message}
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
