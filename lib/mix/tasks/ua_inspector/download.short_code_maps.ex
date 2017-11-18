defmodule Mix.Tasks.UaInspector.Download.ShortCodeMaps do
  @moduledoc """
  Fetches short code map listings from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The listings are extracted from the original PHP source files and stored
  as YAML files in the configured download path.

  `mix ua_inspector.download.short_code_maps`
  """

  @shortdoc "Downloads parser short code maps"

  alias Mix.UAInspector.Download
  alias UAInspector.Config
  alias UAInspector.Downloader
  alias UAInspector.Downloader.ShortCodeMapConverter
  alias UAInspector.ShortCodeMap

  use Mix.Task

  @maps [
    ShortCodeMap.ClientBrowsers,
    ShortCodeMap.DeviceBrands,
    ShortCodeMap.MobileBrowsers,
    ShortCodeMap.OSs
  ]

  def run(args) do
    Mix.shell().info("UAInspector Short Code Map Download")

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
    :ok = Download.prepare_database_path()
    :ok = download(@maps)

    Mix.shell().info("Download complete!")

    :ok
  end

  defp download([]), do: :ok

  defp download([map | maps]) do
    Mix.shell().info(".. downloading: #{map.file_local}")

    yaml = Path.join([Config.database_path(), map.file_local])
    temp = "#{yaml}.tmp"

    Downloader.download_file(map.file_remote, temp)

    :ok =
      map.var_name
      |> ShortCodeMapConverter.extract(map.var_type, temp)
      |> ShortCodeMapConverter.write_yaml(map.var_type, yaml)

    File.rm!(temp)

    download(maps)
  end
end
