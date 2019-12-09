defmodule CivilBus.Subscriber do
  @moduledoc """
  Implementing your subscriber:

  defmodule MySubscriber do
    use CivilBus.Subscriber, channel: :my_channel

    def handle_event(event, state) do
      # Do something with the event
      {:noreply, state}
    end

    #optional:
    def handle_info(:message, state) do
      # Do something with message
      {:noreply, state}
    end

    #Consider adding a catch all case to avoid message box being overflowing.
    def handle_info(_, state), do: {:noreply, state}

    def init_state, do: %{}
  end
  """

  @doc """
  Notifies a subscriber synchronously. The `handle_event/2` function is called directly to ensure
  that it is run in the same process. This is helpful when making a notification in an Ecto.Transaction.
  If call was made in a different process, the transaction would not be available.

  WARNING: State is not updated in the process for this function.
  """
  def notify_sync(pid, module, event) do
    state = :sys.get_state(pid)
    result = module.handle_event(event, state)
    :ok = CivilBus.ack(state.subscription, event)
    result
  end

  @doc """
  Notify subscriber asynchronously.
  """
  def notify_async(pid, event) do
    send(pid, {:events, [%{data: event}]})
  end

  defmacro __using__(opts) do
    channel = Keyword.fetch!(opts, :channel)

    quote do
      use GenServer

      def start_link(_opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      def init(:ok) do
        {:ok, subscription} = CivilBus.subscribe(__MODULE__, unquote(channel), unquote(opts))

        {:ok, Map.put(init_state(), :subscription, subscription)}
      end

      def handle_info({:subscribed, _pid}, state) do
        {:noreply, state}
      end

      def handle_info({:event, event}, state) do
        {tag, new_state} = handle_event(event.data, state)

        :ok = CivilBus.ack(state.subscription, event)

        # This message is required for testing to confirm that an acknowledgement was sent
        # by the subscriber.
        send(self(), :acknowledged)

        {tag, new_state}
      end

      def handle_info({:events, _events} = message, state) do
        CivilBus.handle_info(message, state)
      end

      def init_state(), do: %{}
      defoverridable init_state: 0
    end
  end
end
