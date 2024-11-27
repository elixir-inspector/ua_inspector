defmodule UAInspector.Database.Bots do
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
    [{"", "bot.bots.yml", Config.database_url(:bot, "bots.yml")}]
  end

  defp parse_yaml_entries({:ok, entries}, _) do
    Enum.map(entries, fn data ->
      data = Enum.into(data, %{})

      {
        Util.Regex.build_regex(data["regex"]),
        {
          Util.YAML.maybe_to_string(data["category"]) || :unknown,
          data["name"],
          Util.YAML.maybe_to_string(data["url"]) || :unknown,
          producer_info(data["producer"])
        }
      }
    end)
  end

  defp parse_yaml_entries({:error, error}, database) do
    _ =
      if !Config.get(:startup_silent) do
        Logger.info("Failed to load database #{database}: #{inspect(error)}")
      end

    []
  end

  defp producer_info(nil), do: nil

  defp producer_info(info) do
    info = Enum.into(info, %{})

    {info["name"], info["url"] || :unknown}
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
