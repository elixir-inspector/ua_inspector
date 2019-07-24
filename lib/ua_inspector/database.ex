defmodule UAInspector.Database do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use UAInspector.Storage.Server

      require Logger

      alias UAInspector.Config
      alias UAInspector.Util.YAML

      @behaviour unquote(__MODULE__)

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
    end
  end

  @doc """
  Returns the database sources.
  """
  @callback sources() :: [{binary, binary, binary}]

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any, type :: String.t()) :: term
end
