defmodule Expert.Runtime.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  @impl true
  def init(init_arg) do
    name = init_arg[:name]
    lsp_pid = init_arg[:lsp_pid]
    hidden_folder = init_arg[:path]
    File.mkdir_p!(hidden_folder)
    File.write!(Path.join(hidden_folder, ".gitignore"), "*\n")

    children = [
      {Expert.Runtime,
       init_arg[:runtime] ++
         [name: name, parent: lsp_pid, lsp_pid: lsp_pid]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
