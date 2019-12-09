defmodule CivilBus.EventStoreCase do
  use ExUnit.CaseTemplate

  alias EventStore.Config
  alias CivilBus.ProcessHelper

  using do
    quote do
      import CivilBus.EventStoreCase

      def assert_down(pid) do
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _, _, _}
      end
    end
  end

  setup do
    {conn, registry} = start_event_store()
    on_exit(fn -> shutdown_event_store(conn, registry) end)

    {:ok, %{conn: conn}}
  end

  defp start_event_store() do
    config = Config.parsed(CivilBus.EventStore.Repo, :civil_bus)
    postgrex_config = Config.default_postgrex_opts(config)
    registry = Application.get_env(:eventstore, :registry, :local)

    {:ok, conn} = Postgrex.start_link(postgrex_config)

    EventStore.Storage.Initializer.reset!(conn)

    after_reset(registry)

    {:ok, _} = Application.ensure_all_started(:eventstore)

    {conn, registry}
  end

  defp after_reset(:local) do
    {:ok, _} = Application.ensure_all_started(:eventstore)
  end

  defp shutdown_event_store(conn, registry) do
    after_exit(registry)
    ProcessHelper.shutdown(conn)
  end

  defp after_exit(:local) do
    Application.stop(:eventstore)
  end
end
