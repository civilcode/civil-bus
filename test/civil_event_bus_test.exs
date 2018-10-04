defmodule CivilEventBusTest do
  use CivilEventBus.TestCase

  setup do
    {:ok, pid} = CivilEventBus.start_link()

    on_exit(fn -> assert_down(pid) end)

    :ok
  end

  defmodule MyEvent do
    defstruct data: "important data"
  end

  describe "publishing" do
    test "subscribes to the same channel receives the event" do
      :ok = CivilEventBus.subscribe(:my_channel)
      :ok = CivilEventBus.publish(:my_channel, %MyEvent{})

      receive do
        {:events, _events} = msg ->
          CivilEventBus.handle_info(msg, nil)
      after
        100 -> IO.puts("no event received")
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
