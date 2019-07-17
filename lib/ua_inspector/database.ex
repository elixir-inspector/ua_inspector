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
          database = Path.join(Config.database_path(), local)
          contents = YAML.read_file(database)

          [
            case contents do
              {:ok, entries} ->
                Enum.map(entries, &to_ets(&1, type))

              {:error, error} ->
                _ = Logger.info("Failed to load database #{database}: #{inspect(error)}")
                []
            end
            | acc
          ]
        end)
        |> List.flatten()
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
