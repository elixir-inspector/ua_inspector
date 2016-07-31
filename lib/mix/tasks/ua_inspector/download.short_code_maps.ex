defmodule Mix.Tasks.UaInspector.Download.ShortCodeMaps do
  @moduledoc false
  @shortdoc  "Downloads parser short code maps"

  use Mix.Task

  defdelegate run(args), to: Mix.UAInspector.Download.ShortCodeMaps
end
