defmodule UAInspector.ClientHints.Browsers do
  @moduledoc false

  use UAInspector.Storage.Server

  require Logger

  alias UAInspector.Config
  alias UAInspector.Util.YAML

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Returns the local and remote sources for this database.
  """
  @callback source() :: {binary, binary}
  def source do
    {"client_hints.browsers.yml", Config.database_url(:client_hints, "/browsers.yml")}
  end

  defp parse_yaml_entries({:ok, entries}, _), do: Map.new(entries)

  defp parse_yaml_entries({:error, error}, database) do
    _ =
      unless Config.get(:startup_silent) do
        Logger.info("Failed to load client hints #{database}: #{inspect(error)}")
      end

    %{}
  end

  defp read_database do
    {local, _remote} = source()
    database = Path.join([Config.database_path(), local])

    database
    |> YAML.read_file()
    |> parse_yaml_entries(database)
  end
end
