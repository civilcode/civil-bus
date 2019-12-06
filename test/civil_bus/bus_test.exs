defmodule CivilBusTest do
  use CivilBus.EventStoreCase

  setup do
    {:ok, pid} = CivilBus.start_link()

    on_exit(fn -> assert_down(pid) end)

    :ok
  end

  defmodule MyEvent do
    defstruct data: "important data"
  end

  @assert_timeout 300

  describe "publishing" do
    test "subscribes to the same channel receives the event" do
      {:ok, _subscription} = CivilBus.subscribe(__MODULE__, :my_channel)
      :ok = CivilBus.publish(:my_channel, %MyEvent{})

      receive do
        {:events, _events} = msg ->
          CivilBus.handle_info(msg, nil)
      after
        @assert_timeout - 20 -> IO.puts("no event received")
      end

      assert_receive {:event, %{data: %MyEvent{}}}, @assert_timeout
    end

    test "subscribes to another channel does not receive the event" do
      {:ok, _subscription} = CivilBus.subscribe(__MODULE__, :my_channel)
      :ok = CivilBus.publish(:another_channel, %MyEvent{})
      refute_receive {:event, %MyEvent{}}
    end
  end
end
