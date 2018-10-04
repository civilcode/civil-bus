defmodule CivilEventBusTest do
  use CivilEventBus.TestCase

  setup do
    {:ok, pid} = CivilEventBus.start_link()

    on_exit(fn -> assert_down(pid) end)

    :ok
  end

  defmodule MyEvent do
    defstruct foo: :bar
  end

  describe "publishing" do
    test "subscribes to the same channel receives the event" do
      :ok = CivilEventBus.subscribe(:my_channel)
      :ok = CivilEventBus.publish(:my_channel, %MyEvent{})

      receive do
        {:events, _} = msg ->
          _ = CivilEventBus.handle_info(msg, nil)
      end

      assert_received {:event, %MyEvent{}}
    end

    test "subscribes to another channel does not receive the event" do
      :ok = CivilEventBus.subscribe(:my_channel)
      :ok = CivilEventBus.publish(:another_channel, %MyEvent{})
      refute_received {:event, %MyEvent{}}
    end
  end
end
