defmodule CivilEventBus.TestCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      import CivilEventBus.TestCase

      def assert_down(pid) do
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _, _, _}
      end
    end
  end
end
