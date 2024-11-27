defmodule UAInspector.Database.DevicesNotebooks do
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
    [{"", "device.notebooks.yml", Config.database_url(:device, "notebooks.yml")}]
  end

  defp parse_models(%{"device" => device, "model" => model, "regex" => regex}) do
    [
      {
        Util.Regex.build_regex(regex),
        {
          nil,
          device,
          Util.YAML.maybe_to_string(model)
        }
      }
    ]
  end

  defp parse_models(%{"models" => models}) do
    Enum.map(models, fn model ->
      model = Enum.into(model, %{})

      {
        Util.Regex.build_regex(model["regex"]),
        {
          Util.YAML.maybe_to_string(model["brand"]),
          Util.YAML.maybe_to_string(model["device"]),
          Util.YAML.maybe_to_string(model["model"])
        }
      }
    end)
  end

  defp parse_yaml_entries({:ok, entries}, _, type) do
    Enum.map(entries, fn {brand, data} ->
      data = Enum.into(data, %{})
      models = parse_models(data)

      {
        Util.Regex.build_regex(data["regex"]),
        {
          Util.YAML.maybe_to_string(brand),
          models,
          Util.YAML.maybe_to_string(data["device"]),
          type
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
