defmodule Engine.MixProject do
  use Mix.Project

  def project do
    [
      app: :engine,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Engine.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:forge, path: "../forge"},
      {:spitfire, "~> 0.1"},
      {:elixir_sense, github: "elixir-lsp/elixir_sense"},
      {:path_glob, "~> 0.2.0"},
      {:sourceror, "~> 1.0"},
      # {:gen_lsp, "~> 0.10"},
      {:gen_lsp,
       github: "elixir-tools/gen_lsp", branch: "change-schematic-function", override: true},
      {:namespace, path: "../namespace", runtime: false}
    ]
  end
end
