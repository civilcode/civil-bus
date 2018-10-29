defmodule CivilBus.StorageCase do
  use ExUnit.CaseTemplate

  alias EventStore.Config
  alias CivilBus.ProcessHelper

  using do
    quote do
      import CivilBus.StorageCase

      def assert_down(pid) do
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _, _, _}
      end
    end
  end

  setup do
    config = Config.parsed()
    postgrex_config = Config.default_postgrex_opts(config)
    registry = Application.get_env(:eventstore, :registry, :local)

    {:ok, conn} = Postgrex.start_link(postgrex_config)

    EventStore.Storage.Initializer.reset!(conn)

    after_reset(registry)

    on_exit(fn ->
      after_exit(registry)
      ProcessHelper.shutdown(conn)
    end)

    {:ok, %{conn: conn}}
  end

  defp after_exit(:local) do
    Application.stop(:eventstore)
  end

  defp after_reset(:local) do
    {:ok, _} = Application.ensure_all_started(:eventstore)
  end
end
