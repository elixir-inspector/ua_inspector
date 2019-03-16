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

  def run(args) do
    Mix.shell().info("UAInspector Database Download")

    :ok = Config.init_env()

    case Config.database_path() do
      nil -> exit_unconfigured()
      _ -> args |> request_confirmation() |> run_confirmed()
    end
  end

  defp exit_unconfigured do
    Mix.shell().error("Database path not configured.")
    Mix.shell().error("See README.md for details.")
  end

  defp request_confirmation(args) do
    Mix.shell().info("Download path: #{Config.database_path()}")
    Mix.shell().info("This command will overwrite any existing files!")

    {opts, _argv, _errors} =
      OptionParser.parse(args, strict: [force: :boolean], aliases: [f: :force])

    case opts[:force] do
      true -> true
      _ -> "Really download?" |> Mix.shell().yes?()
    end
  end

  defp run_confirmed(false) do
    Mix.shell().info("Download aborted!")

    :ok
  end

  defp run_confirmed(true) do
    :ok = Downloader.download(:databases)
    :ok = Downloader.download(:short_code_maps)

    Mix.shell().info("Download complete!")

    :ok
  end
end
