defmodule Mix.Tasks.UaInspector.Download.Databases do
  @moduledoc false
  @shortdoc false

  alias Mix.UAInspector.Download
  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  def run(args) do
    Mix.shell().info("UAInspector Parser Database Download")

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

    Mix.shell().info("Download complete!")

    :ok
  end
end
