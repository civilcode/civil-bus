# CivilBus

CivilBus is a wrapper for different implementations of an event bus. Currently the following
are supported:

  * [Elixir Register](https://hexdocs.pm/elixir/master/Registry.html) as a [dispatcher](https://hexdocs.pm/elixir/master/Registry.html#module-using-as-a-dispatcher)
  * [EventStore](https://github.com/commanded/eventstore)

CivilBus was created with the intention to support [domain and integration events](http://rethinkingdesign.tech/2017/10/02/ddd-domain-and-integration-events/).

Domain events have the following characteristics:

  * contain value objects (aka domain primitives)
  * normally synchronous and handled in the same database transaction
  * not stored for the long term (except for event sourcing systems)
  * contain the delta of the event

In contrast to integration events:

  * contain simple primitives only
  * normally asynchronous and handled outside a database transaction
  * maybe stored for the long term for debugging or retries

In reality, depending on your implementation it's possible to mix these characteristics. However,
the most important rule is, if the event is not handled in the same transaction, a delta must
be provided in the event payload.

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
    {:eventstore, "~> 1.0"},
    {:jason, "~> 1.1"}
  ]
end

# config.exs
config :my_app, event_stores: [CivilBus.EventStore.Repo]

config :civil_bus, impl: CivilBus.EventStore

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
