defmodule CivilBus do
  @moduledoc """
  An event bus. A facade for `CivilBus.Behaviour`.
  """

  @behaviour CivilBus.Behaviour

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

  @impl true
  def ack(channel, event) do
    impl().ack(channel, event)
  end

  def handle_info({:events, events}, state) do
    for event <- events, do: send(self(), {:event, event})

    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end

  def impl() do
    Application.get_env(:civil_bus, :impl, CivilBus.EventStore)
  end
end
