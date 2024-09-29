defmodule Expert.LSPSupervisor do
  @moduledoc false

  use Supervisor

  @env Mix.env()

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    if @env == :test do
      :ignore
    else
      {m, f, a} = Application.get_env(:expert, :arg_parser)

      argv = apply(m, f, a)

      {opts, _, _invalid} =
        OptionParser.parse(argv,
          strict: [version: :boolean, help: :boolean, stdio: :boolean, port: :integer]
        )

      help_text = """
      Expert v#{Expert.version()}

      The #{IO.ANSI.italic()}#{IO.ANSI.bright()}official#{IO.ANSI.reset()} language server for Elixir.

          Authors: Mitchell Hanberg, Steve Cohen, Łukasz Samson
        Home page: https://www.expert-lsp.org
      Source code: https://github.com/elixir-lang/expert

      expert [flags]

      #{IO.ANSI.bright()}FLAGS#{IO.ANSI.reset()}

        --stdio             Use stdio as the transport mechanism
        --port <port>       Use TCP as the transport mechanism, with the given port
        --help              Show help
        --version           Show nextls version
      """

      cond do
        opts[:help] ->
          IO.puts(help_text)

          System.halt(0)

        opts[:version] ->
          IO.puts("#{Expert.version()}")
          System.halt(0)

        true ->
          :noop
      end

      buffer_opts =
        cond do
          opts[:stdio] ->
            []

          is_integer(opts[:port]) ->
            IO.puts("Starting on port #{opts[:port]}")
            [communication: {GenLSP.Communication.TCP, [port: opts[:port]]}]

          true ->
            IO.puts(help_text)

            System.halt(1)
        end

      children = [
        {DynamicSupervisor, name: Expert.DynamicSupervisor},
        {GenLSP.Buffer, [name: Expert.Buffer] ++ buffer_opts},
        {Expert, buffer: Expert.Buffer, dynamic_supervisor: Expert.DynamicSupervisor}
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
end
