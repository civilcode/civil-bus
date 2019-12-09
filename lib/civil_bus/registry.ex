defmodule CivilBus.Registry do
  @moduledoc """
  Registry implementation for the CivilBus.
  """

  @behaviour CivilBus.Behaviour

  @default_consistency :eventual

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
    consistency = Keyword.get(opts, :consistency, @default_consistency)

    Registry.register(__MODULE__, channel, {module, Keyword.put(opts, :consistency, consistency)})
  end

  @impl true
  def publish(channel, event) do
    Registry.dispatch(__MODULE__, channel, &notify(&1, event))

    :ok
  end

  defp notify(entries, event) do
    for {pid, {_module, opts}} <- entries do
      case Keyword.fetch!(opts, :consistency) do
        :strong ->
          GenServer.call(pid, {:event, %{data: event}})

        :eventual ->
          send(pid, {:events, [%{data: event}]})
      end
    end
  end

  @impl true
  def ack(_subscription, _event) do
    :ok
  end
end
