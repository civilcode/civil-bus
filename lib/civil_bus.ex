defmodule CivilBus do
  @moduledoc """
  An event bus. A facade for `CivilBus.Behaviour`.
  """

  @behaviour CivilBus.Behaviour

  @doc """
  Starts the CivilBus implementation. This needs to be started in your applications supervision
  tree:

    children = [
      %{
        id: CivilBus,
        start: {CivilBus, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: MagasinData.Supervisor]
    Supervisor.start_link(children, opts)
  """
  @impl true
  def start_link(opts \\ []) do
    impl().start_link(opts)
  end

  @doc """
  Subscribe to a channel on the event bus.

      CivilBus.subscribe(MyModule, :my_channel])

  Typically this is done through the `CivilBus.Subscriber` macro, for example:

      defmodule MyModule do
        use CivilBus.Subcriber, channel: :my_channel
      end
  """
  @impl true
  def subscribe(module, channel) do
    impl().subscribe(module, channel)
  end

  @doc """
  Publishes an event to the channel.

      CivilBus.publish(:my_channel, %MyEvent{})
  """
  @impl true
  def publish(channel, event) do
    impl().publish(channel, event)
  end

  @doc """
  Acknowledge that we have received an event. Not all implementations require an acknowledgement.
  e.g. `CivilBus.Registry`.
  """
  @impl true
  def ack(channel, event) do
    impl().ack(channel, event)
  end

  @doc """
  Called by the `CivilBus.Subscriber` to split a list of events into individual messages.
  """
  def handle_info({:events, events}, state) do
    for event <- events, do: send(self(), {:event, event})

    {:noreply, state}
  end

  @doc """
  Handle unknown messages as not to overflow the mailbox.
  """
  def handle_info(_message, state) do
    {:noreply, state}
  end

  def impl() do
    Application.get_env(:civil_bus, :impl, CivilBus.EventStore)
  end
end
