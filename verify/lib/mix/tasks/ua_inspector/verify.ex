defmodule Mix.Tasks.Ua_inspector.Verify do
  use Mix.Task

  alias Mix.Tasks.Ua_inspector.Verify

  def run(_args) do
    :ok = Verify.Fixtures.download()

    :ok
  end
end
