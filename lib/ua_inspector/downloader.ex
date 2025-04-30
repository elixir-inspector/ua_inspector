defmodule UAInspector.Downloader do
  @moduledoc """
  Fetches copies of the configured database files.

  All files will be stored in the configured database path with the default
  setting being the result of `Application.app_dir(:ua_inspector, "priv")`.

  Please consult `UAInspector.Config` for details on database configuration.

  ## Mix Task

  Please see `Mix.Tasks.UaInspector.Download` if you are interested in
  using a mix task to obtain your database files.
  """

  alias UAInspector.ClientHints
  alias UAInspector.Config
  alias UAInspector.Database
  alias UAInspector.Downloader.ShortCodeMapConverter
  alias UAInspector.ShortCodeMap

  require Logger

  @client_hints [
    ClientHints.Apps,
    ClientHints.Browsers
  ]

  @databases [
    Database.Bots,
    Database.BrowserEngines,
    Database.Clients,
    Database.DevicesHbbTV,
    Database.DevicesNotebooks,
    Database.DevicesRegular,
    Database.DevicesShellTV,
    Database.OSs,
    Database.VendorFragments
  ]

  @short_code_maps [
    ShortCodeMap.BrowserFamilies,
    ShortCodeMap.ClientBrowsers,
    ShortCodeMap.ClientHintBrowserMapping,
    ShortCodeMap.ClientHintOSMapping,
    ShortCodeMap.DesktopFamilies,
    ShortCodeMap.MobileBrowsers,
    ShortCodeMap.OSFamilies,
    ShortCodeMap.OSs,
    ShortCodeMap.VersionMappingFireOS,
    ShortCodeMap.VersionMappingLineageOS
  ]

  @doc """
  Performs download of all files.
  """
  @spec download() :: :ok
  def download do
    :ok = download(:client_hints)
    :ok = download(:databases)
    :ok = download(:short_code_maps)
    :ok
  end

  @doc """
  Performs download of configured database files and short code maps.
  """
  @spec download(:client_hints | :databases | :short_code_maps) :: :ok
  def download(:client_hints) do
    File.mkdir_p!(Config.database_path())

    Enum.each(@client_hints, fn client_hint ->
      {local, remote} = client_hint.source()
      target = Path.join([Config.database_path(), local])

      :ok = download_file(remote, target)
    end)
  end

  def download(:databases) do
    File.mkdir_p!(Config.database_path())

    Enum.each(@databases, fn database ->
      Enum.each(database.sources(), fn {_type, local, remote} ->
        target = Path.join([Config.database_path(), local])

        :ok = download_file(remote, target)
      end)
    end)
  end

  def download(:short_code_maps) do
    File.mkdir_p!(Config.database_path())

    Enum.each(@short_code_maps, fn short_code_map ->
      {local, remote} = short_code_map.source()

      yaml = Path.join(Config.database_path(), local)
      temp = "#{yaml}.tmp"

      :ok = download_file(remote, temp)

      :ok =
        short_code_map.var_name()
        |> ShortCodeMapConverter.extract(short_code_map.var_type(), temp)
        |> ShortCodeMapConverter.write_yaml(short_code_map.var_type(), yaml)

      :ok = File.rm!(temp)
    end)
  end

  defp download_file(remote, local) do
    case Config.downloader_adapter().read_remote(remote) do
      {:ok, content} ->
        File.write!(local, content)
        :ok

      {:error, reason} ->
        Logger.error("Failed to download file: #{reason}")
        :ok
    end
  end
end
