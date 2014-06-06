defmodule ExAgent.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup_all do
        { :ok, _ } = ExAgent.Server.start_link([])
        :ok
      end

      teardown_all do
        :ok = ExAgent.Server.stop()
      end
    end
  end
end
