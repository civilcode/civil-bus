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
  def subscribe(module, channel, opts) do
    Registry.register(__MODULE__, channel, {module, opts})
  end

  @impl true
  def publish(channel, event) do
    Registry.dispatch(__MODULE__, channel, &notify(&1, event))

    :ok
  end

  defp notify(entries, event) do
    for {pid, {_module, opts}} <- entries do
      if Keyword.get(opts, :consistency) == :strong do
        GenServer.call(pid, {:event, %{data: event}})
      else
        send(pid, {:events, [%{data: event}]})
      end
    end
  end

  @impl true
  def ack(_subscription, _event) do
    :ok
  end
end
