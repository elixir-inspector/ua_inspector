defmodule Mix.Tasks.UaInspector.Download.Databases do
  @moduledoc false
  @shortdoc  "Downloads parser databases"

  use Mix.Task

  defdelegate run(args), to: Mix.UAInspector.Download.Databases
end
