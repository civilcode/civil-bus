defmodule CivilBus.MixProject do
  use Mix.Project

  def project do
    [
      app: :civil_bus,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger],
      mod: {CivilBus.Application, []}
    ]
  end

  defp deps do
    [
      {:eventstore, "~> 0.16"},
      {:poison, "~> 3.0"},
      {:mix_test_watch, "~> 0.5", only: :test, runtime: false}
    ]
  end
end
