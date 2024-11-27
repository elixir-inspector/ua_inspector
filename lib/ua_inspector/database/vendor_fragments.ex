defmodule UAInspector.Database.VendorFragments do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util

  @behaviour UAInspector.Storage.Database

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl UAInspector.Storage.Database
  def sources do
    [
      {"", "vendor_fragment.vendorfragments.yml",
       Config.database_url(:vendor_fragment, "vendorfragments.yml")}
    ]
  end

  defp parse_yaml_entries({:ok, entries}, _) do
    Enum.map(entries, fn {brand, regexes} ->
      Enum.map(regexes, &{Util.Regex.build_regex(&1), brand})
    end)
  end

  defp parse_yaml_entries({:error, error}, database) do
    _ =
      if !Config.get(:startup_silent) do
        Logger.info("Failed to load database #{database}: #{inspect(error)}")
      end

    []
  end

  defp read_database do
    sources()
    |> Enum.reverse()
    |> Enum.reduce([], fn {_, local, _remote}, acc ->
      database = Path.join([Config.database_path(), local])

      contents =
        database
        |> Util.YAML.read_file()
        |> parse_yaml_entries(database)

      [contents | acc]
    end)
    |> List.flatten()
  end
end
