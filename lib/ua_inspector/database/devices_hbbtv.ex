defmodule UAInspector.Database.DevicesHbbTV do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util
  alias UAInspector.Util.YAML

  @behaviour UAInspector.Database

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def sources do
    [{"", "device.televisions.yml", Config.database_url(:device, "televisions.yml")}]
  end

  def to_ets({brand, data}, type) do
    data = Enum.into(data, %{})
    models = parse_models(data)

    {
      Util.build_regex(data["regex"]),
      {
        brand,
        models,
        data["device"],
        type
      }
    }
  end

  defp parse_models(data) do
    device = data["device"]

    if data["model"] do
      [
        {
          Util.build_regex(data["regex"]),
          {
            nil,
            device,
            data["model"] || ""
          }
        }
      ]
    else
      Enum.map(data["models"], fn model ->
        model = Enum.into(model, %{})

        {
          Util.build_regex(model["regex"]),
          {
            model["brand"],
            model["device"] || device,
            model["model"] || ""
          }
        }
      end)
    end
  end

  defp parse_yaml_entries({:ok, entries}, type, _) do
    Enum.map(entries, &to_ets(&1, type))
  end

  defp parse_yaml_entries({:error, error}, _, database) do
    _ =
      unless Config.get(:startup_silent) do
        Logger.info("Failed to load database #{database}: #{inspect(error)}")
      end

    []
  end

  defp read_database do
    sources()
    |> Enum.reverse()
    |> Enum.reduce([], fn {type, local, _remote}, acc ->
      database = Path.join([Config.database_path(), local])

      contents =
        database
        |> YAML.read_file()
        |> parse_yaml_entries(type, database)

      [contents | acc]
    end)
    |> List.flatten()
  end
end
