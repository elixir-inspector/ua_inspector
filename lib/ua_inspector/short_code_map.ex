defmodule UAInspector.ShortCodeMap do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use UAInspector.Storage.Server

      require Logger

      alias UAInspector.Config
      alias UAInspector.Storage.ETS
      alias UAInspector.Util.YAML

      @behaviour unquote(__MODULE__)

      defp read_database do
        {local, _} = source()
        map = Path.join(Config.database_path(), local)

        case File.regular?(map) do
          false ->
            _ = Logger.info("failed to load short code map: #{map}")
            []

          true ->
            map
            |> YAML.read_file()
            |> Enum.map(&to_ets/1)
        end
      end
    end
  end

  @doc """
  Returns the local and remote sources for this map.
  """
  @callback source() :: {binary, binary}

  @doc """
  Returns a name representation for this map.
  """
  @callback var_name() :: String.t()

  @doc """
  Returns a type representation for this map.
  """
  @callback var_type() :: :hash | :list | :hash_with_list

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any) :: term
end
