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

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
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
    {strong_notifications, eventual_notifications} = split_subscribers(subscribers)

    # Send of strong notifications first to ensure consistency
    notify_sync(strong_notifications, event)
    notify_async(eventual_notifications, event)
  end

  defp split_subscribers(subscribers) do
    Enum.split_with(subscribers, fn {_pid, {_module, opts}} ->
      Keyword.fetch!(opts, :consistency) == :strong
    end)
  end

  defp notify_sync(subscribers, event) do
    for {pid, {module, _opts}} <- subscribers do
      try do
        Subscriber.notify_sync(pid, module, event)
      catch
        kind, reason -> report(kind, reason, __STACKTRACE__)
      end
    end
  end

  defp notify_async(subscribers, event) do
    for {pid, _} <- subscribers do
      try do
        Subscriber.notify_async(pid, event)
      catch
        kind, reason -> report(kind, reason, __STACKTRACE__)
      end
    end
  end

  defp report(kind, reason, stacktrace) do
    require Logger

    formatted = Exception.format(kind, reason, stacktrace)
    Logger.error("Registry.dispatch/3 failed with #{formatted}")
  end

  @impl true
  def ack(_subscription, _event) do
    :ok
  end
end
