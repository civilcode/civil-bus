defmodule CivilBus.Registry do
  @moduledoc """
  Registry implementation for the CivilBus.
  """

  @behaviour CivilBus.Behaviour

  @impl true
  def start_link(_opts \\ []) do
    Registry.start_link(
      keys: :duplicate,
      name: __MODULE__,
      partitions: System.schedulers_online()
    )
  end

  @impl true
  def subscribe(channel) do
    {:ok, _} = Registry.register(__MODULE__, channel, [])

    :ok
  end

  @impl true
  def publish(channel, event) do
    Registry.dispatch(__MODULE__, channel, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:events, [%{data: event}]})
    end)

    :ok
  end
end
