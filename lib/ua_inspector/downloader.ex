defmodule UAInspector.Downloader do
  @moduledoc """
  Fetches copies of the configured database files.

  All files will be stored in the configured database path with the default
  setting being the result of `Application.app_dir(:ua_inspector, "priv")`.

  Please consult `UAInspector.Config` for details on database configuration.

  ## Mix Task

  Please see `Mix Tasks.UaInspector.Download` if you are interested in
  using a mix task to obtain your database files.
  """

  alias UAInspector.Config
  alias UAInspector.Database
  alias UAInspector.Downloader.README
  alias UAInspector.Downloader.ShortCodeMapConverter
  alias UAInspector.ShortCodeMap

  @databases [
    Database.Bots,
    Database.BrowserEngines,
    Database.Clients,
    Database.DevicesHbbTV,
    Database.DevicesRegular,
    Database.OSs,
    Database.VendorFragments
  ]

  @short_code_maps [
    ShortCodeMap.ClientBrowsers,
    ShortCodeMap.DesktopFamilies,
    ShortCodeMap.DeviceBrands,
    ShortCodeMap.MobileBrowsers,
    ShortCodeMap.OSFamilies,
    ShortCodeMap.OSs
  ]

  @doc """
  Performs download of all files.
  """
  @spec download() :: :ok
  def download do
    :ok = download(:databases)
    :ok = download(:short_code_maps)
    :ok
  end

  @doc """
  Performs download of configured database files and short code maps.
  """
  @spec download(:databases | :short_code_maps) :: :ok
  def download(:databases) do
    :ok = prepare_database_path()

    Enum.each(@databases, fn database ->
      Enum.each(database.sources, fn {_type, local, remote} ->
        target = Path.join([Config.database_path(), local])

        :ok = download_file(remote, target)
      end)
    end)
  end

  def download(:short_code_maps) do
    :ok = prepare_database_path()

    Enum.each(@short_code_maps, fn short_code_map ->
      {local, remote} = short_code_map.source()

      yaml = Path.join(Config.database_path(), local)
      temp = "#{yaml}.tmp"

      :ok = download_file(remote, temp)

      :ok =
        short_code_map.var_name
        |> ShortCodeMapConverter.extract(short_code_map.var_type, temp)
        |> ShortCodeMapConverter.write_yaml(short_code_map.var_type, yaml)

      :ok = File.rm!(temp)
    end)
  end

  @doc """
  Prepares the local database path for downloads.
  """
  @spec prepare_database_path() :: :ok
  def prepare_database_path do
    unless File.dir?(Config.database_path()) do
      File.mkdir_p!(Config.database_path())
    end

    README.write()
  end

  @doc """
  Reads a remote file and returns it's contents.

  Uses the module returned by `Config.downloader_adpater/0`.
  """
  @spec read_remote(binary) :: {:ok, binary} | {:error, term}
  def read_remote(location), do: Config.downloader_adapter().read_remote(location)

  defp download_file(remote, local) do
    {:ok, content} = read_remote(remote)

    File.write!(local, content)
  end
end
