defmodule Mix.Tasks.UaInspector.Download.Databases do
  @moduledoc """
  Fetches parser databases from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The files will be stored inside your configured path.

  `mix ua_inspector.download.databases`
  """

  @shortdoc "Downloads parser databases"

  alias Mix.UAInspector.Download
  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  def run(args) do
    Mix.shell().info("UAInspector Database Download")

    case Config.database_path() do
      nil -> Download.exit_unconfigured()
      _ -> Download.request_confirmation(args) |> run_confirmed()
    end
  end

  defp run_confirmed(false) do
    Mix.shell().info("Download aborted!")

    :ok
  end

  defp run_confirmed(true) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    :ok = Downloader.download(:databases)

    Mix.shell().info("Download complete!")

    :ok
  end
end
