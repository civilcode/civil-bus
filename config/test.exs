use Mix.Config

config :logger, backends: []

config :civil_bus, CivilBus.EventStore.Repo,
  serializer: EventStore.JsonbSerializer,
  column_data_type: "jsonb",
  types: EventStore.PostgresTypes,
  username: "postgres",
  password: "postgres",
  database: "eventstore_test",
  hostname: "db",
  pool_size: 10,
  pool_overflow: 5
