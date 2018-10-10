defmodule CivilBus.Subscriber do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use GenServer

      def start_link(_opts \\ []) do
        GenServer.start_link(__MODULE__, :ok, [])
      end

      def init(:ok) do
        CivilBus.subscribe(unquote(opts[:channel]))

        {:ok, init_state()}
      end

      def handle_info({:event, event}, state) do
        handle_event(event, state)
      end

      def handle_info(message, state) do
        CivilBus.handle_info(message, state)
      end
    end
  end
end
