defmodule Mix.Tasks.UaInspector.Download do
  @moduledoc """
  Mix task to download database file(s) from your command line.

  The task will display the target location upon invocation and will ask for
  confirmation before downloading. If you want to force a download you can
  use `mix ua_inspector.download --force`.
  """

  @shortdoc "Downloads database files"

  alias Mix.UAInspector.Download
  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  def run(args) do
    Mix.shell().info("UAInspector Database Download")

    :ok = Config.init_env()

    case Config.database_path() do
      nil -> Download.exit_unconfigured()
      _ -> args |> Download.request_confirmation() |> run_confirmed()
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
