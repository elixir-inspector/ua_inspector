defmodule UAInspector.Database.DevicesHbbTV do
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
    [{"", "device.televisions.yml", Config.database_url(:device, "televisions.yml")}]
  end

  defp maybe_to_string(nil), do: nil
  defp maybe_to_string(val) when is_binary(val), do: val
  defp maybe_to_string(val), do: to_string(val)

  defp parse_models(%{"device" => device, "model" => model, "regex" => regex}) do
    [
      {
        Util.build_regex(regex),
        {
          nil,
          device,
          model || ""
        }
      }
    ]
  end

  defp parse_models(%{"models" => models}) do
    Enum.map(models, fn model ->
      model = Enum.into(model, %{})

      {
        Util.build_regex(model["regex"]),
        {
          maybe_to_string(model["brand"]),
          model["device"],
          model["model"] || ""
        }
      }
    end)
  end

  defp parse_yaml_entries({:ok, entries}, _, type) do
    Enum.map(entries, fn {brand, data} ->
      data = Enum.into(data, %{})
      models = parse_models(data)

      {
        Util.build_regex(data["regex"]),
        {
          maybe_to_string(brand),
          models,
          data["device"],
          type
        }
      }
    end)
  end

  defp parse_yaml_entries({:error, error}, database, _) do
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
        |> parse_yaml_entries(database, type)

      [contents | acc]
    end)
    |> List.flatten()
  end
end
