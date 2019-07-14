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
        |> Enum.flat_map(fn {type, local, _remote} ->
          database = Path.join(Config.database_path(), local)
          contents = YAML.read_file(database)

          case contents do
            {:ok, entries} ->
              entries
              |> Enum.map(&to_ets(&1, type))
              |> List.flatten()

            {:error, error} ->
              _ = Logger.info("Failed to load database #{database}: #{inspect(error)}")
              []
          end
        end)
        |> Enum.with_index()
        |> Enum.map(fn {entry, index} -> {index, entry} end)
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
