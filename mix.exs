defmodule CivilEventBus.MixProject do
  use Mix.Project

  def project do
    [
      app: :civil_event_bus,
      version: "0.1.0",
      elixir: "~> 1.7",
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
      mod: {CivilEventBus.Application, []}
    ]
  end

  defp deps do
    [
      {:eventstore, "~> 0.15.1"},
      {:poison, "~> 3.0"},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end