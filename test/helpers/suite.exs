defmodule ExAgent.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup do
        { :ok, _ } = ExAgent.Server.start_link([])

        on_exit fn ->
          :ok = ExAgent.Server.stop()
        end

        ExAgent.TestHelper.Regexes.yaml_fixture() |> ExAgent.load_yaml()
      end
    end
  end
end
