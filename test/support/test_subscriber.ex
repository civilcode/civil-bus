defmodule CivilBus.TestSubscriber do
  use CivilBus.Subscriber, channel: :my_channel

  def received?(subscriber, event) do
    GenServer.call(subscriber, {:received?, event})
  end

  def handle_event(event, :subscribed), do: handle_event(event, [])

  def handle_event(event, state) do
    {:noreply, [event | state]}
  end

  def handle_call({:received?, event}, from, :subscribed) do
    handle_call({:received?, event}, from, [])
  end

  def handle_call({:received?, event}, _from, state) do
    {:reply, Enum.member?(state, event), state}
  end
end