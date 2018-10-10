defmodule CivilBus.SubscriptionTestCase do
  import CivilBus.SharedTestCase

  define_tests do
    setup do
      {:ok, pid} = CivilBus.start_link()

      on_exit(fn -> assert_down(pid) end)

      :ok
    end

    defmodule MyEvent do
      defstruct data: "event data"
    end

    alias CivilBus.TestSubscriber

    describe "receiving" do
      test "receives an event" do
        {:ok, subscriber} = TestSubscriber.start_link()

        :ok = CivilBus.publish(:my_channel, %MyEvent{})

        TestSubscriber.received?(subscriber, %MyEvent{})
      end

      test "two subscribers receive an event" do
        {:ok, subscriber_1} = TestSubscriber.start_link()
        {:ok, subscriber_2} = TestSubscriber.start_link()

        :ok = CivilBus.publish(:my_channel, %MyEvent{})

        TestSubscriber.received?(subscriber_1, %MyEvent{})
        TestSubscriber.received?(subscriber_2, %MyEvent{})
      end
    end
  end
end
