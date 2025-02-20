defmodule Lexical.Protocol.MixProject do
  use Mix.Project
  Code.require_file("../../mix_includes.exs")

  def project do
    [
      app: :protocol,
      env: Mix.env(),
      version: "0.7.2",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: Mix.Dialyzer.config(add_apps: [:jason]),
      consolidate_protocols: Mix.env() != :test,
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ~w(lib test/support)
  defp elixirc_paths(_), do: ~w(lib)

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:common, path: "../common", env: Mix.env()},
      Mix.Credo.dependency(),
      Mix.Dialyzer.dependency(),
      {:jason, "~> 1.4", optional: true},
      {:patch, "~> 0.15", only: [:test]},
      {:proto, path: "../proto", env: Mix.env()}
    ]
  end
end
