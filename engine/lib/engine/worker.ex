defmodule Engine.Worker do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl GenServer
  def init(_arg) do
    working_dir = File.cwd!()
    {:ok, %{working_dir: working_dir}}
  end

  def enqueue_compiler(opts) do
    GenServer.cast(__MODULE__, {:compile, opts})
  end

  defp flush(acc) do
    receive do
      {:"$gen_cast", {:compile, opts}} -> flush([opts | acc])
    after
      0 -> acc
    end
  end

  @impl GenServer
  def handle_cast({:compile, opts}, state) do
    # we essentially compile now and rollup any newer requests to compile, so that we aren't doing 5 compiles
    # if we the user saves 5 times after saving one time
    flush([])
    from = Keyword.fetch!(opts, :from)

    File.cd!(state.working_dir)

    result = Engine.Worker.compile()

    Process.send(from, {:compiler_result, result}, [])
    {:noreply, state}
  end

  def compile do
    # keep stdout on this node
    Process.group_leader(self(), Process.whereis(:user))

    Mix.Task.clear()

    # load the paths for deps and compile them
    # will noop if they are already compiled
    # The mix cli basically runs this before any mix task
    # we have to rerun because we already ran a mix task
    # (mix run), which called this, but we also passed
    # --no-compile, so nothing was compiled, but the
    # task was not re-enabled it seems
    Mix.Task.rerun("deps.loadpaths")

    Mix.Task.rerun("compile", [
      "--ignore-module-conflict",
      "--no-protocol-consolidation",
      "--return-errors"
    ])
  rescue
    e -> {:error, e}
  end
end
