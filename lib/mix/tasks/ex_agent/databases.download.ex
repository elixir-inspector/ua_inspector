defmodule Mix.Tasks.Ex_agent.Databases.Download do
  use Mix.Task

  @shortdoc  "Downloads regexes.yaml"

  @moduledoc """
  Fetches parser databases from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The files will be stored inside your MIX_HOME (defaults to ~/.mix).

  `mix ex_agent.database.download`
  """

  def run(_args) do
    Mix.shell.info("Download path: #{ Mix.ExAgent.download_path() }")
    Mix.shell.info("This command will delete all existing files before downloading!")

    if Mix.shell.yes?("Download parser databases?") do
      clear()
      setup()
      download()
    end
  end

  defp clear() do
    { :ok, _ } = File.rm_rf Mix.ExAgent.download_path
  end

  defp download() do
    databases = ExAgent.Database.Clients.sources ++
                ExAgent.Database.Devices.sources ++
                ExAgent.Database.Oss.sources

    for { local, remote } <- databases do
      download_database(local, remote)
    end
  end

  defp download_database(local, remote) do
    target = Path.join([ Mix.ExAgent.download_path, local ])

    IO.puts ".. downloading: #{ local }"
    File.write! target, Mix.Utils.read_path!(remote)
  end

  defp setup() do
    :ok = File.mkdir_p Mix.ExAgent.download_path

    readme_src = Path.join([ __DIR__, "../../files/README.md" ])
    readme_tgt = Path.join([ Mix.ExAgent.download_path, "README.md" ])

    { :ok, _ } = File.copy readme_src, readme_tgt
  end
end