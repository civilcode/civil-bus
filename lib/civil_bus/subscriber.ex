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

      # {:event, EventStore.EventDate}
      def handle_info({:event, event}, state) do
        application_event = CivilBus.get_application_event(event) # delegate EventStore/Register
        
        handle_event(application_event, state)
        
        CivilBus.ack(unquote(opts[:channel]), event)
      end

      def handle_info(message, state) do
        CivilBus.handle_info(message, state)
      end
    end
  end
end
