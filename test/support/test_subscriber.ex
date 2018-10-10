defmodule CivilBus.TestSubscriber do
  use CivilBus.Subscriber, channel: :my_channel
  
  def init_state() do
    %{notifier: nil}
  end

  def add_notifier(subscriber, notifier) do
    GenServer.call(subscriber, {:notifier, notifier}) 
  end

  def handle_event(event, state) do
    send(state.notifier, {self(), event})
    {:noreply, state}
  end

  def handle_call({:notifier, notifier}, _from, state) do
    {:reply, :ok, Map.put(state, :notifier, notifier)}
  end
end