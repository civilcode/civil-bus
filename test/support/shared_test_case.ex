defmodule CivilBus.SharedTestCase do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import CivilBus.SharedTestCase
    end
  end

  defmodule TestCase do
    use ExUnit.CaseTemplate

    using do
      quote do
        def assert_down(pid) do
          ref = Process.monitor(pid)
          assert_receive {:DOWN, ^ref, _, _, _}
        end
      end
    end
  end

  @doc """
  Define tests to be shared across other test cases.
  """
  defmacro define_tests(do: block) do
    quote do
      defmacro __using__(options) do
        block = unquote(Macro.escape(block))

        quote do
          use TestCase

          @moduletag unquote(options)
          unquote(block)
        end
      end
    end
  end
end
