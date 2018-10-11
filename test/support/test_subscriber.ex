defmodule CivilBus.TestSubscriber do
  use CivilBus.Subscriber, channel: :my_channel

  def init_state() do
    %{listener: nil}
  end

  def add_listener(subscriber, listener) do
    GenServer.call(subscriber, {:listener, listener})
  end

  def handle_event(event, state) do
    send(state.listener, {self(), event})
    {:noreply, state}
  end

  def handle_call({:listener, listener}, _from, state) do
    {:reply, :ok, Map.put(state, :listener, listener)}
  end

  def handle_info(:acknowledged, state) do
    send(state.listener, {self(), :acknowledged})

    {:noreply, state}
  end
end
