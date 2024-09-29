defmodule Expert.MixProject do
  use Mix.Project

  def project do
    [
      app: :expert,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      releases: releases(),
      default_release: :expert,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Expert.Application, []}
    ]
  end

  def releases do
    [
      plain: [],
      expert: [
        steps: [:assemble, &Expert.Release.assemble/1, &Burrito.wrap/1],
        burrito: [
          targets: [
            darwin_arm64: [os: :darwin, cpu: :aarch64],
            darwin_amd64: [os: :darwin, cpu: :x86_64],
            linux_arm64: [os: :linux, cpu: :aarch64],
            linux_amd64: [os: :linux, cpu: :x86_64],
            windows_amd64: [os: :windows, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_lsp,
       github: "elixir-tools/gen_lsp", branch: "change-schematic-function", override: true},
      # {:gen_lsp, "~> 0.10"},
      {:burrito, "~> 1.0", only: [:dev, :prod]},
      {:namespace, path: "../namespace", only: [:dev]}
    ]
  end
end
