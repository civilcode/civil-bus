{:ok, _} = Application.ensure_all_started(:eventstore)

ExUnit.start()
