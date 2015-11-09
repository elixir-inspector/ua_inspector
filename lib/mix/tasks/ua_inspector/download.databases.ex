if Version.match?(System.version, ">= 1.0.3") do
  #
  # Elixir 1.0.3 and up requires mixed case module namings.
  # The "double uppercase letter" of "UAInspector" violates
  # this rule. This fake task acts as a workaround.
  #
  defmodule Mix.Tasks.UaInspector.Download.Databases do
    @moduledoc false
    @shortdoc  "Downloads parser databases"

    use Mix.Task

    defdelegate run(args), to: Mix.UAInspector.Download.Databases
  end
else
  #
  # Elixir 1.0.2 requires the underscore module naming.
  # https://github.com/elixytics/ua_inspector/pull/1
  #
  defmodule Mix.Tasks.Ua_inspector.Download.Databases do
    @moduledoc false
    @shortdoc  "Downloads parser databases"

    use Mix.Task

    defdelegate run(args), to: Mix.UAInspector.Download.Databases
  end
end
