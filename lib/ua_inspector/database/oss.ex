defmodule UAInspector.Database.OSs do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util
  alias UAInspector.Util.YAML

  @behaviour UAInspector.Database

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl UAInspector.Database
  def sources do
    [{"", "os.oss.yml", Config.database_url(:os, "oss.yml")}]
  end

  defp oss_versions(versions) do
    Enum.map(versions, fn data ->
      data = Enum.into(data, %{})

      {
        Util.build_regex(data["regex"]),
        data["version"]
      }
    end)
  end

  defp parse_yaml_entries({:ok, entries}, _) do
    Enum.map(entries, fn data ->
      data = Enum.into(data, %{})

      {
        Util.build_regex(data["regex"]),
        {
          data["name"] || "",
          to_string(data["version"] || ""),
          oss_versions(data["versions"] || [])
        }
      }
    end)
  end

  defp parse_yaml_entries({:error, error}, database) do
    _ =
      unless Config.get(:startup_silent) do
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
        |> YAML.read_file()
        |> parse_yaml_entries(database)

      [contents | acc]
    end)
    |> List.flatten()
  end
end
