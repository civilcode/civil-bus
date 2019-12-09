defmodule CivilBus.Registry do
  @moduledoc """
  Registry implementation for the CivilBus.
  """

  @behaviour CivilBus.Behaviour

  @default_consistency :eventual

  alias CivilBus.Subscriber

  @impl true
  def start_link(_opts \\ []) do
    Registry.start_link(
      keys: :duplicate,
      name: __MODULE__,
      partitions: System.schedulers_online()
    )
  end

  @impl true
  def subscribe(module, channel, opts) do
    consistency = Keyword.get(opts, :consistency, @default_consistency)

    Registry.register(__MODULE__, channel, {module, Keyword.put(opts, :consistency, consistency)})
  end

  @impl true
  def publish(channel, event) do
    Registry.dispatch(__MODULE__, channel, &notify(&1, event))

    :ok
  end

  defp notify(subscribers, event) do
    {strong_notifications, eventual_notifications} =
      Enum.split_with(subscribers, fn {_pid, {_module, opts}} ->
        Keyword.fetch!(opts, :consistency) == :strong
      end)

    # Send of strong notifications first to ensure consistency
    for {pid, {module, _opts}} <- strong_notifications do
      Subscriber.notify_sync(pid, module, event)
    end

    for {pid, _} <- eventual_notifications do
      Subscriber.notify_async(pid, event)
    end
  end

  @impl true
  def ack(_subscription, _event) do
    :ok
  end
end
