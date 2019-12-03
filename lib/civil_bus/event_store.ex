if CivilBus.Config.impl() == CivilBus.EventStore do
  defmodule CivilBus.EventStore do
    @moduledoc """
    EventStore implementation for the CivilBus.
    """

    defmodule Repo do
      use EventStore, otp_app: :civil_bus

      def init(config) do
        runtime = Application.fetch_env!(:civil_bus, CivilBus.EventStore.Repo)
        {:ok, runtime ++ config}
      end
    end

    @behaviour CivilBus.Behaviour

    @impl true
    def start_link(_opts \\ []) do
      {:ok, :event_store}
    end

    @impl true
    def subscribe(module, channel) do
      Repo.subscribe_to_stream(to_string(channel), to_string(module), self())
    end

    @impl true
    def publish(channel, event) do
      events = [
        %EventStore.EventData{
          event_type: to_string(event.__struct__),
          data: event
        }
      ]

      :ok = Repo.append_to_stream(to_string(channel), :any_version, events)
    end

    @impl true
    def ack(subscription, event) do
      Repo.ack(subscription, event)
    end
  end
end
