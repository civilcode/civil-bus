defmodule CivilBus.SubscriptionTestCase do
  import CivilBus.SharedTestCase

  define_tests do
    defmodule MyEvent do
      defstruct data: "event data"
    end

    alias CivilBus.TestSubscriber

    describe "receiving" do
      test "receives an event" do
        {:ok, subscriber} = TestSubscriber.start_link()
        TestSubscriber.add_notifier(subscriber, self())

        :ok = CivilBus.publish(:my_channel, %MyEvent{})

        assert_receive {^subscriber, %MyEvent{}}
        assert_receive {^subscriber, :acknowledged}, 200
      end

      test "two subscribers receive an event" do
        {:ok, subscriber_1} = TestSubscriber.start_link()
        TestSubscriber.add_notifier(subscriber_1, self())
        {:ok, subscriber_2} = TestSubscriber.start_link()
        TestSubscriber.add_notifier(subscriber_2, self())

        :ok = CivilBus.publish(:my_channel, %MyEvent{})

        assert_receive {^subscriber_1, %MyEvent{}}
        assert_receive {^subscriber_1, :acknowledged}, 200
        assert_receive {^subscriber_2, %MyEvent{}}
        assert_receive {^subscriber_2, :acknowledged}, 200
      end
    end
  end
end
