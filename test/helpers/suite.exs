defmodule ExAgent.TestHelper.Suite do
  defmacro __using__(_) do
    quote do
      setup do
        { :ok, pid } = ExAgent.Server.start_link([])

        on_exit fn ->
          if Process.alive?(pid) do
            Process.exit(pid, :kill)
          end
        end

        ExAgent.TestHelper.Regexes.yaml_fixture() |> ExAgent.load_yaml()
      end
    end
  end
end
