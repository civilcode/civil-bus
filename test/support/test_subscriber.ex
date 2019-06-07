# As the module name is used to identify the subscription, multiple test subscribers are required
# when testing multiple subscriptions.
#
for subscriber <- [CivilBus.TestSubscriber, CivilBus.TestSubscriber1, CivilBus.TestSubscriber2] do
  defmodule subscriber do
    @moduledoc """
    The test subscriber is used to relay messages back to the test case. For example:

      {:ok, subscriber} = TestSubscriber.start_link()
      TestSubscriber.add_listener(subscriber, self())

      :ok = CivilBus.publish(:my_channel, %MyEvent{})

      assert_receive {^subscriber, %MyEvent{}}
      assert_receive {^subscriber, :acknowledged}
    """
    use CivilBus.Subscriber, channel: :my_channel

    # Public API

    def add_listener(subscriber, listener) do
      GenServer.call(subscriber, {:add_listener, listener})
    end

    # Callbacks

    def handle_event(event, state) do
      send(state.listener, {self(), event})
      {:noreply, state}
    end

    def handle_call({:add_listener, listener}, _from, state) do
      {:reply, :ok, Map.put(state, :listener, listener)}
    end

    def handle_info(:acknowledged, state) do
      send(state.listener, {self(), :acknowledged})

      {:noreply, state}
    end

    def handle_info(_, state), do: {:noreply, state}
  end
end
