defmodule Mix.Tasks.UaInspector.Download do
  @moduledoc """
  Fetches databases from the
  [matomo-org/device-detector](https://github.com/matomo-org/device-detector)
  project.

  The files will be stored inside your configured path.

  `mix ua_inspector.download`
  """

  @shortdoc "Downloads UAInspector databases"

  alias Mix.UAInspector.Download
  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  def run(args) do
    Mix.shell().info("UAInspector Database Download")

    :ok = Config.init_env()

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
    :ok = Downloader.download(:short_code_maps)

    Mix.shell().info("Download complete!")

    :ok
  end
end
