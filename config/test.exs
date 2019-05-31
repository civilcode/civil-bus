use Mix.Config

config :logger, backends: []

config :eventstore, column_data_type: "jsonb"

config :eventstore, EventStore.Storage,
  serializer: EventStore.JsonbSerializer,
  types: EventStore.PostgresTypes,
  username: "postgres",
  password: "postgres",
  database: "eventstore_test",
  hostname: "db",
  pool_size: 10,
  pool_overflow: 5
