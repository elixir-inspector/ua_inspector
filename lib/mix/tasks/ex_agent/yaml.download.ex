defmodule Mix.Tasks.Ex_agent.Yaml.Download do
  use Mix.Task

  @yaml_repo "https://github.com/tobie/ua-parser"
  @yaml_url  "https://raw.github.com/tobie/ua-parser/master/regexes.yaml"
  @shortdoc  "Downloads regexes.yaml"

  @moduledoc """
  Fetch a copy of regexes.yaml from #{ @yaml_repo }.
  The copy will be stored inside your MIX_HOME (defaults to ~/.mix).

  Full path to your copy: MIX_HOME/ex_agent/regexes.yaml

  `mix ex_agent.yaml.download`
  """

  def run(_args) do
    Mix.shell.info("Download path: #{ Mix.ExAgent.local_yaml() }")

    if File.regular?(Mix.ExAgent.local_yaml()) do
      if Mix.shell.yes?("Overwrite existing regexes.yaml?") do
        download_yaml()
      end
    else
      if Mix.shell.yes?("Download regexes.yaml?") do
        download_yaml()
      end
    end
  end

  defp download_yaml() do
    File.mkdir_p! Path.dirname(Mix.ExAgent.local_yaml())
    File.write! Mix.ExAgent.local_yaml(), Mix.Utils.read_path!(@yaml_url)
  end
end