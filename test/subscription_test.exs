defmodule CivilBus.Registry.SubscriptionTest do
  use CivilBus.SubscriptionTestCase

  setup do
    default_implementation = Application.get_env(:event_bus, :impl)
    Application.put_env(:event_bus, :impl, CivilBus.Registry)

    on_exit(fn -> Application.put_env(:event_bus, :impl, default_implementation) end)

    :ok
  end

  test "running against correct implementation" do
    assert Application.get_env(:event_bus, :impl) == CivilBus.Registry
  end
end

defmodule CivilBus.EventStore.SubscriptionTest do
  use CivilBus.SubscriptionTestCase

  setup do
    default_implementation = Application.get_env(:event_bus, :impl)
    Application.put_env(:event_bus, :impl, CivilBus.EventStore)

    on_exit(fn -> Application.put_env(:event_bus, :impl, default_implementation) end)

    :ok
  end

  test "running against correct implementation" do
    assert Application.get_env(:event_bus, :impl) == CivilBus.EventStore
  end
end
