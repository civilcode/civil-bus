use Mix.Config

config :civil_bus, impl: CivilBus.EventStore

import_config "#{Mix.env()}.exs"
