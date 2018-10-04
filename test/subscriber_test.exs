defmodule SubscriberTest do
  use CivilEventBus.TestCase

  setup do
    {:ok, pid} = CivilEventBus.start_link()

    on_exit(fn -> assert_down(pid) end)

    :ok
  end

  defmodule MyEvent do
    defstruct foo: "bar"
  end

  defmodule TestSubscriber do
    use CivilEventBus.Subscriber, channel: :my_channel

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

  describe "receiving" do
    test "receives an event" do
      {:ok, subscriber} = TestSubscriber.start_link()

      :ok = CivilEventBus.publish(:my_channel, %MyEvent{})

      assert TestSubscriber.received?(subscriber, %MyEvent{})
    end

    test "two subscribers receive an event" do
      {:ok, subscriber_1} = TestSubscriber.start_link()
      {:ok, subscriber_2} = TestSubscriber.start_link()

      :ok = CivilEventBus.publish(:my_channel, %MyEvent{})

      assert TestSubscriber.received?(subscriber_1, %MyEvent{})
      assert TestSubscriber.received?(subscriber_2, %MyEvent{})
    end
  end
end