if Version.match?(System.version, ">= 1.0.3") do
  #
  # Elixir 1.0.3 and up requires mixed case module namings.
  # The "double uppercase letter" of "UAInspector" violates
  # this rule. This fake task acts as a workaround.
  #
  defmodule Mix.Tasks.UaInspector.Verify do
    @moduledoc false
    @shortdoc  "Verifies parser results"

    use Mix.Task

    defdelegate run(args), to: Mix.UAInspector.Verify
  end
else
  #
  # Elixir 1.0.2 requires the underscore module naming.
  # https://github.com/elixytics/ua_inspector/pull/1
  #
  defmodule Mix.Tasks.Ua_inspector.Verify do
    @moduledoc false
    @shortdoc  "Verifies parser results"

    use Mix.Task

    defdelegate run(args), to: Mix.UAInspector.Verify
  end
end
