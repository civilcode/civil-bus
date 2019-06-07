defmodule CivilBus.Behaviour do
  @moduledoc """
  Defines the behaviour for CivilBus implementations.
  """

  @type channel :: atom
  @type subscriber :: pid
  @type event :: term
  @type subscription :: pid

  @callback start_link(Keyword.t()) :: {:ok, pid()} | {:error, term}
  @callback subscribe(module, channel) :: {:ok, subscription}
  @callback publish(channel, event) :: :ok
  @callback ack(subscription, event) :: :ok
end
