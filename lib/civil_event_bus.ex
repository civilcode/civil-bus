defmodule CivilEventBus do
  @moduledoc """
  An event bus. A facade for `CivilEventBus.Behaviour`.
  """

  @behaviour CivilEventBus.Behaviour

  @impl true
  def start_link(opts \\ []) do
    impl().start_link(opts)
  end

  @impl true
  def subscribe(channel) do
    impl().subscribe(channel)
  end

  @impl true
  def publish(channel, event) do
    impl().publish(channel, event)
  end

  def handle_info({:events, events}, state) do
    for event <- events, do: send(self(), {:event, event.data})

    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp impl() do
    Application.get_env(:event_bus, :impl, CivilEventBus.EventStore)
  end
end
