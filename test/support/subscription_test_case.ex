defmodule CivilBus.SubscriptionTestCase do
  import CivilBus.SharedTestCase

  define_tests do
    defmodule MyEvent do
      defstruct data: "event data"
    end

    @timeout 300

    alias CivilBus.{TestSubscriber, TestSubscriber1, TestSubscriber2}

    describe "receiving" do
      test "receives an event" do
        {:ok, subscriber} = TestSubscriber.start_link()
        TestSubscriber.add_listener(subscriber, self())

        :ok = CivilBus.publish(:my_channel, %MyEvent{})

        assert_receive {^subscriber, %MyEvent{}}, @timeout
        assert_receive {^subscriber, :acknowledged}, @timeout
      end

      test "two subscribers receive an event" do
        {:ok, subscriber_1} = TestSubscriber1.start_link()
        TestSubscriber.add_listener(subscriber_1, self())
        {:ok, subscriber_2} = TestSubscriber2.start_link()
        TestSubscriber.add_listener(subscriber_2, self())

        :ok = CivilBus.publish(:my_channel, %MyEvent{})

        assert_receive {^subscriber_1, %MyEvent{}}, @timeout
        assert_receive {^subscriber_1, :acknowledged}, @timeout
        assert_receive {^subscriber_2, %MyEvent{}}, @timeout
        assert_receive {^subscriber_2, :acknowledged}, @timeout
      end
    end
  end
end
