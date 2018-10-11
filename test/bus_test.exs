defmodule CivilBusTest do
  use CivilBus.StorageCase

  setup do
    {:ok, _pid} = CivilBus.start_link()

    :ok
  end

  defmodule MyEvent do
    defstruct data: "important data"
  end

  @assert_timeout 300

  describe "publishing" do
    test "subscribes to the same channel receives the event" do
      :ok = CivilBus.subscribe(:my_channel)
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
      :ok = CivilBus.subscribe(:my_channel)
      :ok = CivilBus.publish(:another_channel, %MyEvent{})
      refute_receive {:event, %MyEvent{}}
    end
  end
end
