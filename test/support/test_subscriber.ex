defmodule CivilBus.TestSubscriber do
  use CivilBus.Subscriber, channel: :my_channel

  def received?(subscriber, event) do
    GenServer.call(subscriber, {:received?, event})
  end

  def handle_event(event, nil), do: handle_event(event, [])

  def handle_event(event, state) do
    {:noreply, [event | state]}
  end

  def handle_call({:received?, event}, from, nil) do
    handle_call({:received?, event}, from, [])
  end

  def handle_call({:received?, event}, _from, state) do
    {:reply, Enum.member?(state, event), state}
  end
end