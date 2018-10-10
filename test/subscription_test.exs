defmodule CivilBus.Registry.SubscriptionTest do
  use CivilBus.SubscriptionTestCase

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
end

defmodule CivilBus.EventStore.SubscriptionTest do
  use CivilBus.SubscriptionTestCase

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
