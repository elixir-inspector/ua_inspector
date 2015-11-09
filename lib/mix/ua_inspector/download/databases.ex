defmodule Mix.UAInspector.Download.Databases do
  @moduledoc """
  Fetches parser databases from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The files will be stored inside your configured path.

  `mix ua_inspector.download.databases`
  """

  alias Mix.UAInspector.Download

  alias UAInspector.Config
  alias UAInspector.Database


  @behaviour Mix.Task

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
      Mix.shell.info ".. downloading: #{ local }"

      target = Path.join([ Config.database_path, local ])

      download_database(remote, target)
    end

    download(databases)
  end

  if Version.match?(System.version, ">= 1.1.0") do
    defp download_database(remote, local) do
      { :ok, content } = Mix.Utils.read_path(remote)

      File.write! local, content
    end
  else
    defp download_database(remote, local) do
      File.write! local, Mix.Utils.read_path!(remote)
    end
  end
end
