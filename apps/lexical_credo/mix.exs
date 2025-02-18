defmodule LexicalCredo.MixProject do
  use Mix.Project

  @repo_url "https://github.com/lexical-lsp/lexical/"
  @version "0.5.0"

  def project do
    [
      app: :lexical_credo,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      env: [lexical_plugin: true]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:common, in_umbrella: true},
      {:credo, "> 0.0.0", optional: true},
      {:jason, "> 0.0.0", optional: true},
      {:ex_doc, "~> 0.34", optional: true, only: [:dev, :hex]}
    ]
  end

  defp docs do
    [
      extras: ["README.md": [title: "Overview"]],
      main: "readme",
      homepage_url: @repo_url,
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end
end
