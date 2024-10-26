defmodule Expert.Runtime do
  @moduledoc false
  use GenServer

  defguardp is_ready(state) when is_map_key(state, :node)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @type mod_fun_arg :: {atom(), atom(), list()}

  @spec call(pid(), mod_fun_arg()) :: any()
  def call(server, mfa) do
    GenServer.call(server, {:call, mfa}, :infinity)
  end

  @spec expand(pid(), Macro.t(), String.t()) :: any()
  def expand(server, ast, file) do
    GenServer.call(server, {:expand, ast, file}, :infinity)
  end

  @spec ready?(pid()) :: boolean()
  def ready?(server), do: GenServer.call(server, :ready?)

  @spec await(pid(), non_neg_integer()) :: :ok | :timeout
  def await(server, count \\ 50)

  def await(_server, 0) do
    :timeout
  end

  def await(server, count) do
    with {:alive, true} <- {:alive, Process.alive?(server)},
         true <- ready?(server) do
      :ok
    else
      {:alive, false} ->
        :timeout

      _ ->
        Process.sleep(500)
        await(server, count - 1)
    end
  end

  @spec compile(pid(), Keyword.t()) :: any()
  def compile(server, opts \\ []) do
    GenServer.call(server, {:compile, opts}, :infinity)
  end

  def boot(supervisor, opts) do
    DynamicSupervisor.start_child(supervisor, {Expert.Runtime.Supervisor, opts})
  end

  def stop(supervisor, pid) do
    DynamicSupervisor.terminate_child(supervisor, pid)
  end

  defmacro execute!(runtime, block) do
    quote do
      {:ok, result} = Expert.Runtime.execute(unquote_splicing([runtime, block]))
      result
    end
  end

  defmacro execute(runtime, do: block) do
    exprs =
      case block do
        {:__block__, _, exprs} -> exprs
        expr -> [expr]
      end

    for expr <- exprs, reduce: quote(do: :ok) do
      ast ->
        mfa =
          case expr do
            {{:., _, [mod, func]}, _, args} ->
              [mod, func, args]

            {_func, _, _args} ->
              raise "#{Macro.to_string(__MODULE__)}.execute/2 cannot be called with local functions"
          end

        quote do
          unquote(ast)
          Expert.Runtime.call(unquote(runtime), {unquote_splicing(mfa)})
        end
    end
  end

  @impl GenServer
  def init(opts) do
    sname = "expert-runtime-#{System.system_time()}"
    name = Keyword.fetch!(opts, :name)
    working_dir = Keyword.fetch!(opts, :working_dir)
    lsp_pid = Keyword.fetch!(opts, :lsp_pid)
    # uri = Keyword.fetch!(opts, :uri)
    parent = Keyword.fetch!(opts, :parent)
    on_initialized = Keyword.fetch!(opts, :on_initialized)

    elixir_exe = System.find_executable("elixir")

    pid =
      cond do
        is_pid(parent) -> parent
        is_atom(parent) -> Process.whereis(parent)
      end

    parent =
      pid
      |> :erlang.term_to_binary()
      |> Base.encode64()
      |> String.to_charlist()

    bindir = System.get_env("BINDIR")
    path = System.get_env("PATH")
    path_minus_bindir = String.replace(path, bindir <> ":", "")

    path_minus_bindir2 =
      path_minus_bindir |> String.split(":") |> List.delete(bindir) |> Enum.join(":")

    new_path = elixir_exe <> ":" <> path_minus_bindir2

    case :code.priv_dir(:expert) do
      dir when is_list(dir) ->
        exe =
          dir
          |> Path.join("cmd")
          |> Path.absname()

        env =
          [
            {~c"LSP", ~c"expert"},
            {~c"EXPERT_PARENT_PID", parent},
            {~c"MIX_BUILD_ROOT", ~c".expert-lsp/_build"},
            {~c"ROOTDIR", false},
            {~c"BINDIR", false},
            {~c"RELEASE_ROOT", false},
            {~c"RELEASE_SYS_CONFIG", false},
            {~c"PATH", String.to_charlist(new_path)}
          ]

        engine_path =
          System.get_env("EXPERT_ENGINE_PATH", to_string(dir)) |> Path.expand()

        consolidated =
          Path.wildcard(Path.join(engine_path, "lib/*/{consolidated}"))
          |> Enum.flat_map(fn ep -> ["-pa", ep] end)

        rest =
          Path.wildcard(Path.join(engine_path, "lib/*/{ebin}"))
          |> Enum.flat_map(fn ep -> ["-pa", ep] end)

        engine_path_args = rest ++ consolidated

        args =
          [elixir_exe] ++
            engine_path_args ++
            [
              "--no-halt",
              "--sname",
              sname,
              "--cookie",
              Node.get_cookie(),
              "-S",
              "mix",
              "loadpaths",
              "--no-compile"
            ]

        port =
          Port.open(
            {:spawn_executable, exe},
            [
              :use_stdio,
              :stderr_to_stdout,
              :binary,
              :stream,
              cd: working_dir,
              env: env,
              args: args
            ]
          )

        Port.monitor(port)

        me = self()

        Task.start_link(fn ->
          {:ok, host} = :inet.gethostname()
          node = :"#{sname}@#{host}"

          case connect(node, port, 120) do
            true ->
              {:ok, _} = :rpc.call(node, Application, :ensure_all_started, [:engine])

              send(me, {:node, node})

            error ->
              send(me, {:cancel, error})
          end
        end)

        {:ok,
         %{
           name: name,
           working_dir: working_dir,
           compiler_refs: %{},
           port: port,
           lsp_pid: lsp_pid,
           parent: parent,
           errors: nil,
           on_initialized: on_initialized
         }}

      _ ->
        {:stop, :failed_to_boot}
    end
  end

  @impl GenServer
  def handle_call(:ready?, _from, state) when is_ready(state) do
    {:reply, true, state}
  end

  def handle_call(:ready?, _from, state) do
    {:reply, false, state}
  end

  def handle_call(_, _from, state) when not is_ready(state) do
    {:reply, {:error, :not_ready}, state}
  end

  def handle_call({:call, {m, f, a}}, _from, %{node: node} = state) do
    reply = :rpc.call(node, m, f, a)
    {:reply, {:ok, reply}, state}
  end

  def handle_call({:compile, opts}, _from, %{node: node} = state) do
    opts =
      opts
      |> Keyword.put_new(:working_dir, state.working_dir)
      |> Keyword.put(:from, self())

    with {:badrpc, _error} <-
           :rpc.call(node, Engine.Worker, :enqueue_compiler, [opts]) do
      :error
    end

    {:reply, :ok, state}
  end

  @impl GenServer
  # NOTE: these two callbacks are basically to forward the messages from the runtime to the
  #       LSP process so that progress messages can be dispatched
  def handle_info({:compiler_result, result}, state) do
    # we add the runtime name into the message
    send(state.lsp_pid, {:compiler_result, state.name, result})

    {:noreply, state}
  end

  def handle_info({:DOWN, _, :port, port, _}, %{port: port} = state) do
    unless is_ready(state) do
      state.on_initialized.({:error, :portdown})
    end

    {:noreply, Map.delete(state, :node)}
  end

  def handle_info({:cancel, error}, state) do
    state.on_initialized.({:error, error})
    {:noreply, Map.delete(state, :node)}
  end

  def handle_info({:node, node}, state) do
    Node.monitor(node, true)
    state.on_initialized.(:ready)
    {:noreply, Map.put(state, :node, node)}
  end

  def handle_info({:nodedown, node}, %{node: node} = state) do
    {:stop, {:shutdown, :nodedown}, state}
  end

  def handle_info(
        {port, {:data, "** (Mix) Can't continue due to errors on dependencies" <> _ = _data}},
        %{port: port} = state
      ) do
    Port.close(port)
    state.on_initialized.({:error, :deps})
    {:stop, {:shutdown, :unchecked_dependencies}, state}
  end

  def handle_info({port, {:data, "Unchecked dependencies" <> _ = _data}}, %{port: port} = state) do
    Port.close(port)
    state.on_initialized.({:error, :deps})
    {:stop, {:shutdown, :unchecked_dependencies}, state}
  end

  def handle_info({port, {:data, _data}}, %{port: port} = state) do
    {:noreply, state}
  end

  def handle_info({port, _other}, %{port: port} = state) do
    {:noreply, state}
  end

  defp connect(_node, _port, 0) do
    false
  end

  defp connect(node, port, attempts) do
    if Node.connect(node) in [false, :ignored] do
      Process.sleep(1000)
      connect(node, port, attempts - 1)
    else
      true
    end
  end
end
