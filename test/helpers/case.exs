defmodule ExAgent.TestHelper.Case do
  use ExUnit.CaseTemplate

  setup do
    { :ok, pid } = ExAgent.Server.start_link([])

    on_exit fn ->
      if Process.alive?(pid) do
        Process.exit(pid, :kill)
      end
    end

    ExAgent.TestHelper.Regexes.yaml_fixture() |> ExAgent.load_yaml()
  end

  using do
    quote do
      import ExAgent.TestHelper.Case
    end
  end
end
