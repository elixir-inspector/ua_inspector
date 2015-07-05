defmodule Mix.Tasks.UAInspector.Download.Databases do
  @moduledoc """
  Fetches parser databases from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The files will be stored inside your configured path.

  `mix ua_inspector.download.databases`
  """

  use Mix.Task

  alias Mix.UAInspector.Download

  alias UAInspector.Config
  alias UAInspector.Database


  def run(args) do
    Mix.shell.info "UAInspector Database Download"

    case Config.database_path do
      nil -> Download.exit_unconfigured()
      _   -> Download.request_confirmation(args) |> run_confirmed()
    end
  end


  defp run_confirmed(false) do
    Mix.shell.info "Download aborted!"

    :ok
  end

  defp run_confirmed(true) do
    :ok = Download.prepare_database_path()
    :ok =
         [
           Database.Bots,
           Database.BrowserEngines,
           Database.Clients,
           Database.Devices,
           Database.OSs,
           Database.VendorFragments
         ]
      |> download()

    Mix.shell.info "Download complete!"

    :ok
  end

  defp download([]),                      do: :ok
  defp download([ database | databases ]) do
    for { _type, local, remote } <- database.sources do
      target = Path.join([ Config.database_path, local ])

      Mix.shell.info ".. downloading: #{ local }"
      File.write! target, Mix.Utils.read_path!(remote)
    end

    download(databases)
  end
end

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

    defdelegate run(args), to: Mix.Tasks.UAInspector.Download.Databases
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

    defdelegate run(args), to: Mix.Tasks.UAInspector.Download.Databases
  end
end
