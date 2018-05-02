defmodule Mix.Tasks.UaInspector.Download.ShortCodeMaps do
  @moduledoc """
  Fetches short code map listings from the
  [matomo-org/device-detector](https://github.com/matomo-org/device-detector)
  project.

  The listings are extracted from the original PHP source files and stored
  as YAML files in the configured download path.

  `mix ua_inspector.download.short_code_maps`
  """

  @shortdoc "Downloads parser short code maps"

  alias Mix.UAInspector.Download
  alias UAInspector.Config
  alias UAInspector.Downloader

  use Mix.Task

  def run(args) do
    Mix.shell().info("UAInspector Short Code Map Download")

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
    :ok = Downloader.download(:short_code_maps)

    Mix.shell().info("Download complete!")

    :ok
  end
end
