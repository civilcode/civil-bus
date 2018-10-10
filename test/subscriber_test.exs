defmodule CivilBus.Registry.SubscriberTest do
  use CivilBus.SubscriberTestCase

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

defmodule CivilBus.EventStore.SubscriberTest do
  use CivilBus.SubscriberTestCase

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
