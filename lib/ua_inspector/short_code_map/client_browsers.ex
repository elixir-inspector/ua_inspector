defmodule UAInspector.ShortCodeMap.ClientBrowsers do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util.ShortCodeMap, as: ShortCodeMapUtil
  alias UAInspector.Util.YAML

  @behaviour UAInspector.ShortCodeMap

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl UAInspector.ShortCodeMap
  def source do
    {"short_codes.client_browsers.yml",
     Config.database_url(:short_code_map, "Parser/Client/Browser.php")}
  end

  @impl UAInspector.ShortCodeMap
  def var_name, do: "availableBrowsers"

  @impl UAInspector.ShortCodeMap
  def var_type, do: :hash

  @doc """
  Returns the short code for a client browser.
  """
  @spec to_short(String.t()) :: String.t()
  def to_short(long), do: ShortCodeMapUtil.to_short(list(), long)

  defp read_database do
    {local, _} = source()
    map = Path.join(Config.database_path(), local)

    map
    |> YAML.read_file()
    |> parse_yaml_entries(map)
  end

  defp parse_yaml_entries({:ok, entries}, _) do
    Enum.map(entries, fn [{short, long}] -> {short, long} end)
  end

  defp parse_yaml_entries({:error, error}, map) do
    _ =
      unless Config.get(:startup_silent) do
        Logger.info("Failed to load short code map #{map}: #{inspect(error)}")
      end

    []
  end
end
