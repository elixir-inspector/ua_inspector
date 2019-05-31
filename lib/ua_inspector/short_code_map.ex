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

      def to_long(short) do
        list()
        |> Enum.find({short, short}, fn {s, _} -> short == s end)
        |> elem(1)
      end

      def to_short(long) do
        list()
        |> Enum.find({long, long}, fn {_, l} -> long == l end)
        |> elem(0)
      end

      defp do_reload(ets_tid) do
        {local, _} = source()
        map = Path.join(Config.database_path(), local)

        case File.regular?(map) do
          false ->
            _ = Logger.info("failed to load short code map: #{map}")
            :ok

          true ->
            map
            |> YAML.read_file()
            |> Enum.map(&to_ets/1)
            |> ETS.store_data_entries(ets_tid)
        end
      end
    end
  end

  @doc """
  Returns the local and remote sources for this map.
  """
  @callback source() :: {binary, binary}

  @doc """
  Returns the long representation for a short name.

  Unknown names are returned unmodified.
  """
  @callback to_long(String.t()) :: String.t()

  @doc """
  Returns the short representation for a long name.

  Unknown names are returned unmodified.
  """
  @callback to_short(String.t()) :: String.t()

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
