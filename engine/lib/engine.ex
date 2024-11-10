defmodule Engine do
  def ensure_all_started() do
    Application.ensure_all_started(:engine)
  end
end
