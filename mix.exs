defmodule Expert.LanguageServer.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.7.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      docs: docs(),
      name: "Expert",
      consolidate_protocols: Mix.env() != :test
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      main: "readme",
      deps: [jason: "https://hexdocs.pm/jason/Jason.html"],
      extras: ~w(
        README.md
        pages/installation.md
        pages/architecture.md
        pages/glossary.md
      ),
      filter_modules: fn mod_name, _ ->
        case Module.split(mod_name) do
          ["Expert", "Protocol", "Requests" | _] -> true
          ["Expert", "Protocol", "Notifications" | _] -> true
          ["Expert", "Protocol", "Responses" | _] -> true
          ["Expert", "Protocol" | _] -> false
          _ -> true
        end
      end,
      groups_for_modules: [
        Core: ~r/Expert.^(RemoteControl|Protocol|Server)/,
        "Remote Control": ~r/Expert.RemoteControl/,
        "Protocol Requests": ~r/Expert.Protocol.Requests/,
        "Protocol Notifications": ~r/Expert.Protocol.Notifications/,
        "Protocol Responses": ~r/Expert.Protocol.Responses/,
        Server: ~r/Expert.Server/
      ]
    ]
  end

  defp aliases do
    [
      compile: "compile --docs --debug-info",
      docs: "docs --html",
      test: "test --no-start",
      "nix.hash": &nix_hash/1
    ]
  end

  defp nix_hash(_args) do
    docker = System.get_env("DOCKER_CMD", "docker")

    Mix.shell().cmd(
      "#{docker} run --rm -v '#{File.cwd!()}:/data' nixos/nix nix --extra-experimental-features 'nix-command flakes' run ./data#update-hash",
      stderr_to_stdout: false
    )
  end
end
