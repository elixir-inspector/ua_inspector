defmodule UAInspector.Database.Clients do
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
    # files ordered according to
    # https://github.com/matomo-org/device-detector/blob/master/DeviceDetector.php
    # to prevent false detections
    [
      {"feed reader", "client.feed_readers.yml",
       Config.database_url(:client, "feed_readers.yml")},
      {"mobile app", "client.mobile_apps.yml", Config.database_url(:client, "mobile_apps.yml")},
      {"mediaplayer", "client.mediaplayers.yml",
       Config.database_url(:client, "mediaplayers.yml")},
      {"pim", "client.pim.yml", Config.database_url(:client, "pim.yml")},
      {"browser", "client.browsers.yml", Config.database_url(:client, "browsers.yml")},
      {"library", "client.libraries.yml", Config.database_url(:client, "libraries.yml")}
    ]
  end

  defp parse_yaml_entries({:ok, entries}, _, type) do
    Enum.map(entries, fn data ->
      data = Enum.into(data, %{})

      {
        Util.Regex.build_regex(data["regex"]),
        {
          prepare_engine_data(type, data["engine"]),
          Util.YAML.maybe_to_string(data["name"]),
          type,
          Util.YAML.maybe_to_string(data["version"])
        }
      }
    end)
  end

  defp parse_yaml_entries({:error, error}, database, _) do
    _ =
      if !Config.get(:startup_silent) do
        Logger.info("Failed to load database #{database}: #{inspect(error)}")
      end

    []
  end

  defp prepare_engine_data("browser", [{"default", default}, {"versions", non_default}]) do
    non_default =
      non_default
      |> Enum.map(fn {version, name} ->
        {to_string(version), {name, Util.Regex.build_engine_regex(name)}}
      end)
      |> Enum.reverse()

    [{"default", {default, Util.Regex.build_engine_regex(default)}}, {"versions", non_default}]
  end

  defp prepare_engine_data(_, [{"default", default}]) do
    [{"default", {default, Util.Regex.build_engine_regex(default)}}]
  end

  defp prepare_engine_data(_, engine_data), do: engine_data

  defp read_database do
    sources()
    |> Enum.reverse()
    |> Enum.reduce([], fn {type, local, _remote}, acc ->
      database = Path.join([Config.database_path(), local])

      contents =
        database
        |> Util.YAML.read_file()
        |> parse_yaml_entries(database, type)

      [contents | acc]
    end)
    |> List.flatten()
  end
end
