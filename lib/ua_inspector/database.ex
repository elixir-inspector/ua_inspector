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
          database = Config.database_path() |> Path.join(local)

          case File.regular?(database) do
            false ->
              _ = Logger.info("failed to load database: #{database}")
              []

            true ->
              database
              |> YAML.read_file()
              |> Enum.map(&to_ets(&1, type))
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
