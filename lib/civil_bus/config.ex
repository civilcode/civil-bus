defmodule CivilBus.Config do
  def impl() do
    Application.fetch_env!(:civil_bus, :impl)
  end
end
