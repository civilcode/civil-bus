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

  defmacro __using__(opts) do
    quote do
      use GenServer

      def start_link(_opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, [])
      end

      def init(:ok) do
        CivilBus.subscribe(__MODULE__, unquote(opts[:channel]))

        {:ok, init_state()}
      end

      def handle_info({:subscribed, _pid}, state) do
        {:noreply, state}
      end

      def handle_info({:event, event}, state) do
        result = handle_event(event.data, state)

        :ok = CivilBus.ack(unquote(opts[:channel]), event)

        send(self(), :acknowledged)

        result
      end

      def handle_info({:events, _events} = message, state) do
        CivilBus.handle_info(message, state)
      end

      def init_state(), do: %{}
      defoverridable init_state: 0
    end
  end
end
