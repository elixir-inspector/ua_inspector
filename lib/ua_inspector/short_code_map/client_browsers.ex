defmodule UAInspector.ShortCodeMap.ClientBrowsers do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util

  @behaviour UAInspector.Storage.ShortCodeMap

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl UAInspector.Storage.ShortCodeMap
  def source do
    {"short_codes.client_browsers.yml",
     Config.database_url(:short_code_map, "Parser/Client/Browser.php")}
  end

  @impl UAInspector.Storage.ShortCodeMap
  def var_name, do: "availableBrowsers"

  @impl UAInspector.Storage.ShortCodeMap
  def var_type, do: :hash

  @doc """
  Returns the short code using a fuzzy (downcase, no whitespace) long match.
  """
  @spec find_fuzzy(String.t()) :: nil | {String.t(), String.t()}
  def find_fuzzy(long) do
    fuzzy_long_1 = to_fuzzy(long)
    fuzzy_long_2 = fuzzy_long_1 <> "browser"

    Enum.find(list(), fn {_, list_long} ->
      list_long_1 = to_fuzzy(list_long)
      list_long_2 = list_long_1 <> "browser"

      list_long_1 == fuzzy_long_1 || list_long_1 == fuzzy_long_2 || list_long_2 == fuzzy_long_1
    end)
  end

  @doc """
  Returns the short code for a client browser.
  """
  @spec to_short(String.t()) :: String.t()
  def to_short(long), do: Util.ShortCodeMap.to_short(list(), long)

  defp read_database do
    {local, _} = source()
    map = Path.join(Config.database_path(), local)

    map
    |> Util.YAML.read_file()
    |> parse_yaml_entries(map)
  end

  defp parse_yaml_entries({:ok, entries}, _) do
    Enum.map(entries, fn [{short, long}] -> {short, long} end)
  end

  defp parse_yaml_entries({:error, error}, map) do
    _ =
      if !Config.get(:startup_silent) do
        Logger.info("Failed to load short code map #{map}: #{inspect(error)}")
      end

    []
  end

  defp to_fuzzy(value), do: value |> String.replace(" ", "") |> String.downcase()
end
