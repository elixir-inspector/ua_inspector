defmodule Mix.Tasks.Ua_inspector.Databases.Download do
  @moduledoc """
  Fetches parser databases from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The files will be stored inside your configured path.

  `mix ua_inspector.database.download`
  """

  use Mix.Task

  @shortdoc  "Downloads parser databases"

  def run(args) do
    Mix.shell.info "Download path: #{ download_path }"
    Mix.shell.info "This command will delete all existing files before downloading!"

    { opts, _argv, _errors } = OptionParser.parse(args, aliases: [ f: :force ])

    run_confirmed(opts)

    Mix.shell.info "Download complete!"
  end

  defp run_confirmed([ force: true ]), do: run_confirmed(true)
  defp run_confirmed(false),           do: :ok
  defp run_confirmed(true)             do
    clear()
    setup()
    download()
  end
  defp run_confirmed(_) do
    "Download parser databases?"
    |> Mix.shell.yes?()
    |> run_confirmed()
  end

  defp clear(), do: File.rm_rf! download_path

  defp download() do
    databases = UAInspector.Database.Clients.sources ++
                UAInspector.Database.Devices.sources ++
                UAInspector.Database.OSs.sources

    for { local, remote } <- databases do
      download_database(local, remote)
    end
  end

  defp download_database(local, remote) do
    target = Path.join([ download_path, local ])

    Mix.shell.info ".. downloading: #{ local }"
    File.write! target, Mix.Utils.read_path!(remote)
  end

  defp download_path, do: Application.get_env(:ua_inspector, :database_path)

  defp setup() do
    download_path |> File.mkdir_p!

    readme_src = Path.join(__DIR__, "../../files/README.md")
    readme_tgt = Path.join(download_path, "README.md")

    File.copy!(readme_src, readme_tgt)
  end
end
