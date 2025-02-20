defmodule Proto.MixProject do
  use Mix.Project
  Code.require_file("../../mix_includes.exs")

  def project do
    [
      app: :proto,
      version: "0.7.2",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: Mix.Dialyzer.config(add_apps: [:jason])
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:common, path: "../common", env: Mix.env()},
      Mix.Credo.dependency(),
      Mix.Dialyzer.dependency(),
      {:jason, "~> 1.4", optional: true}
    ]
  end
end
