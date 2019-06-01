# CivilBus

CivilBus is a wrapper for different implementations of an event bus. Currently the following
are supported:

* [Elixir Register](https://hexdocs.pm/elixir/master/Registry.html) as a [dispatcher](https://hexdocs.pm/elixir/master/Registry.html#module-using-as-a-dispatcher)
* [EventStore](https://github.com/commanded/eventstore)

## Installation

For use with the Elixir Registry:

```elixir
# mix.exs
def deps do
  [
    {:civil_bus, github: "civilcode/civil-bus"},
  ]
end

# config.exs
config :civil_bus, impl: CivilBus.Registry

# your_app/application.ex (we'll fix the child spec soon)
children = [
  %{
    id: CivilBus,
    start: {CivilBus, :start_link, []}
  }
]

opts = [strategy: :one_for_one, name: MagasinData.Supervisor]
Supervisor.start_link(children, opts)
```

For use with EventStore:

```elixir
# mix.exs
def deps do
  [
    {:civil_bus, github: "civilcode/civil-bus"},
    {:eventstore, "~> 0.16", optional: true},
    {:jason, "~> 1.1", optional: true}
  ]
end

# config.exs
config :civil_bus, impl: CivilBus.EventStore

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
```

As you are probably using Ecto you'll also want to change the schema table as these conflict,
unfortunately we are forced to change the table Ecto uses:

```elixir
config :my_app, MyApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  # avoids conflict with EventStore schema_migrations
  # https://github.com/commanded/eventstore/issues/73
  migration_source: "ecto_schema_migrations"
```

To create the tables required by EventStore:

    mix do event_store.create, event_store.init

For more instructions on the EventStore see the [Getting Started Guide](https://github.com/commanded/eventstore/blob/master/guides/Getting%20Started.md).

## Publish and Subscribe

Create a subscriber:

```elixir
defmodule MagasinCore.Inventory.EventSubscriber do
  @moduledoc false

  use CivilBus.Subscriber, channel: :test

  def handle_event(event, state) do
    {:ok, _} = MagasinCore.Inventory.StockItemApplicationService.handle(event)

    {:noreply, state}
  end
end
```

And add it to your supervision tree:

```elixir
def start(_type, _args) do
  children = [MagasinCore.Inventory.EventSubscriber]

  opts = [strategy: :one_for_one, name: MagasinCore.Supervisor]
  Supervisor.start_link(children, opts)
end
```

And publish an event:

```elixir
CivilBus.publish(:test, %MyEvent{foo: "bar"})
```
