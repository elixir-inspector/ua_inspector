defmodule Mix.Tasks.UaInspector.Download do
  @moduledoc """
  Mix task to download database file(s) from your command line.

  The task will display the target location upon invocation and will ask for
  confirmation before downloading. If you want to force a download you can
  use `mix ua_inspector.download --force`.
  """

  @shortdoc "Downloads database files"

  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  @cli_options [
    aliases: [f: :force],
    strict: [force: :boolean]
  ]

  def run(args) do
    :ok = Config.init_env()

    Mix.shell().info("Download path: #{Config.database_path()}")
    Mix.shell().info("This command will replace any existing files!")

    if request_confirmation(args) do
      perform_download()
    else
      exit_unconfirmed()
    end
  end

  defp exit_unconfirmed do
    Mix.shell().info("Download aborted!")
    :ok
  end

  defp perform_download do
    :ok = Downloader.download(:databases)
    :ok = Downloader.download(:short_code_maps)

    Mix.shell().info("Download complete!")
    :ok
  end

  defp request_confirmation(args) do
    {opts, _argv, _errors} = OptionParser.parse(args, @cli_options)

    case opts[:force] do
      true -> true
      _ -> Mix.shell().yes?("Download databases?")
    end
  end
end
