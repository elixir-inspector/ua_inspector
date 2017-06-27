defmodule Mix.Tasks.UaInspector.Verify do
  @moduledoc false
  @shortdoc  "Verifies parser results"

  use Mix.Task

  defdelegate run(args), to: Mix.UAInspector.Verify
end
