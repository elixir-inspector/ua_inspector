defmodule UAInspector.ClientHints.Browsers do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util

  @behaviour UAInspector.Storage.ClientHints

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl UAInspector.Storage.ClientHints
  def source do
    {"client_hints.browsers.yml", Config.database_url(:client_hints, "/browsers.yml")}
  end

  defp parse_yaml_entries({:ok, entries}, _),
    do: Map.new(entries, fn {k, v} -> {String.downcase(k), v} end)

  defp parse_yaml_entries({:error, error}, database) do
    _ =
      if !Config.get(:startup_silent) do
        Logger.info("Failed to load client hints #{database}: #{inspect(error)}")
      end

    %{}
  end

  defp read_database do
    {local, _remote} = source()
    database = Path.join([Config.database_path(), local])

    database
    |> Util.YAML.read_file()
    |> parse_yaml_entries(database)
  end
end
