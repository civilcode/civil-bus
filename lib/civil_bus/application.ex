defmodule CivilBus.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      if Code.ensure_loaded?(EventStore) do
        # Ensure eventstore is started, as this is an optional dependency
        # so it cannot be defined in :extra_applications
        {:ok, _} = Application.ensure_all_started(:eventstore)
        [CivilBus.EventStore.Repo]
      else
        []
      end

    opts = [strategy: :one_for_one, name: CivilBus.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
