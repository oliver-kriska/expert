defmodule Expert.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    case System.cmd("epmd", ["-daemon"], stderr_to_stdout: true) do
      {_, 0} ->
        :ok

      {output, code} ->
        IO.warn("Failed to start epmd! Exited with code=#{code} and output=#{output}")

        raise "Failed to start epmd!"
    end

    Node.start(:"expert-#{System.system_time()}", :shortnames)

    children = [
      {Forge.Document.Store, derive: [analysis: &Forge.Ast.analyze/1]},
      Expert.LSPSupervisor,
      {DynamicSupervisor, Expert.Project.Supervisor.options()},
      {Task.Supervisor, name: Expert.TaskQueue.task_supervisor_name()},
      TaskQueue
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Expert.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
