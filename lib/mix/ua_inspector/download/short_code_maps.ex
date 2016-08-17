defmodule Mix.UAInspector.Download.ShortCodeMaps do
  @moduledoc """
  Fetches short code map listings from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The listings are extracted from the original PHP source files and stored
  as YAML files in the configured download path.

  `mix ua_inspector.download.short_code_maps`
  """

  alias Mix.UAInspector.Download
  alias Mix.UAInspector.ShortCodeMap, as: Util

  alias UAInspector.Config
  alias UAInspector.ShortCodeMap


  @behaviour Mix.Task

  @maps [
    ShortCodeMap.ClientBrowsers,
    ShortCodeMap.DeviceBrands,
    ShortCodeMap.MobileBrowsers,
    ShortCodeMap.OSs
  ]

  def run(args) do
    Mix.shell.info "UAInspector Short Code Map Download"

    case Config.database_path do
      nil -> Download.exit_unconfigured()
      _   -> Download.request_confirmation(args) |> run_confirmed()
    end
  end



  defp run_confirmed(false) do
    Mix.shell.info "Download aborted!"

    :ok
  end

  defp run_confirmed(true) do
    :ok = Download.prepare_database_path()
    :ok = @maps |> download()

    Mix.shell.info "Download complete!"

    :ok
  end

  defp download([]),            do: :ok
  defp download([ map | maps ]) do
    Mix.shell.info ".. downloading: #{ map.file_local }"

    yaml = Path.join([ Config.database_path, map.file_local ])
    temp = "#{ yaml }.tmp"

    download_database(map.file_remote, temp)

    :ok =
         map.var_name
      |> Util.extract(map.var_type, temp)
      |> Util.write_yaml(map.var_type, yaml)

    File.rm! temp

    download(maps)
  end

  defp download_database(remote, local) do
    { :ok, content } = Download.read_remote(remote)

    File.write! local, content
  end
end
