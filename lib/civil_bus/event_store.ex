defmodule CivilBus.EventStore do
  @moduledoc """
  EventStore implementation for the CivilBus.
  """

  @behaviour CivilBus.Behaviour

  @impl true
  def start_link(_opts \\ []) do
    {:ok, :event_store}
  end

  @impl true
  def subscribe(channel) do
    subscription_name = "subscription_#{inspect(self())}"

    {:ok, _subscription} =
      EventStore.subscribe_to_stream(to_string(channel), subscription_name, self())

    :ok
  end

  @impl true
  def publish(channel, event) do
    events = [
      %EventStore.EventData{
        event_type: to_string(event.__struct__),
        data: event
      }
    ]

    :ok = EventStore.append_to_stream(to_string(channel), :any_version, events)
  end
 
  @impl true 
  def ack(channel, event) do 
    EventStore.ack(channel, event)
  end
end
