# CivilBus

*CivilBus take care of publishing and subscribing to events.*

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `civil_bus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:civil_bus, "~> 0.1.0"}
  ]
end
```

## Setup

    git clone https://github.com/civilcode/civil-bus.git
    cd civil-bus
    docker-compose up -d
    docker-compose exec -e MIX_ENV=test application mix deps.get
    docker-compose exec -e MIX_ENV=test application mix do event_store.create, event_store.init
    docker-compose exec application mix test
