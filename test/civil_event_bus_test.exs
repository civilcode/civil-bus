defmodule CivilEventBusTest do
  use ExUnit.Case
  doctest CivilEventBus

  test "greets the world" do
    assert CivilEventBus.hello() == :world
  end
end
