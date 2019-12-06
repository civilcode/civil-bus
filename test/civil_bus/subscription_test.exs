defmodule CivilBus.Registry.SubscriptionTest do
  use CivilBus.SubscriptionSharedTests

  setup do
    default_implementation = Application.get_env(:civil_bus, :impl)
    Application.put_env(:civil_bus, :impl, CivilBus.Registry)

    {:ok, pid} = CivilBus.start_link()

    on_exit(fn ->
      Application.put_env(:civil_bus, :impl, default_implementation)
      assert_down(pid)
    end)

    :ok
  end

  test "running against correct implementation" do
    assert CivilBus.impl() == CivilBus.Registry
  end

  describe "subsribing with strong consistency" do
    define_subscriber(FooSubscriber, channel: :my_channel, consistency: :strong)

    test "receives an event" do
      {:ok, subscriber} = FooSubscriber.start_link()
      FooSubscriber.add_listener(subscriber, self())

      :ok = CivilBus.publish(:my_channel, %MyEvent{})

      assert_receive {^subscriber, %MyEvent{}}, @timeout
      assert_receive {^subscriber, :acknowledged}, @timeout
    end
  end
end

defmodule CivilBus.EventStore.SubscriptionTest do
  use CivilBus.SubscriptionSharedTests

  setup do
    default_implementation = Application.get_env(:civil_bus, :impl)
    Application.put_env(:civil_bus, :impl, CivilBus.EventStore)

    {:ok, pid} = CivilBus.start_link()

    on_exit(fn ->
      Application.put_env(:civil_bus, :impl, default_implementation)
      assert_down(pid)
    end)

    :ok
  end

  test "running against correct implementation" do
    assert CivilBus.impl() == CivilBus.EventStore
  end
end
