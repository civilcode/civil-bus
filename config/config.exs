use Mix.Config

config :civil_bus, impl: CivilBus.EventStore, event_stores: [CivilBus.EventStore.Repo]

import_config "#{Mix.env()}.exs"
