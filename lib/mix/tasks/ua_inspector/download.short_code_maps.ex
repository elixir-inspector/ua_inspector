if Version.match?(System.version, ">= 1.0.3") do
  #
  # Elixir 1.0.3 and up requires mixed case module namings.
  # The "double uppercase letter" of "UAInspector" violates
  # this rule. This fake task acts as a workaround.
  #
  defmodule Mix.Tasks.UaInspector.Download.ShortCodeMaps do
    @moduledoc false
    @shortdoc  "Downloads parser short code maps"

    use Mix.Task

    defdelegate run(args), to: Mix.UAInspector.Download.ShortCodeMaps
  end
else
  #
  # Elixir 1.0.2 requires the underscore module naming.
  #
  defmodule Mix.Tasks.Ua_inspector.Download.Short_code_maps do
    @moduledoc false
    @shortdoc  "Downloads parser short code maps"

    use Mix.Task

    defdelegate run(args), to: Mix.UAInspector.Download.ShortCodeMaps
  end
end
