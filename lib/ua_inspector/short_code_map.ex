defmodule UAInspector.ShortCodeMap do
  @moduledoc """
  Basic short code map module providing minimal functions.
  """

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)

      @behaviour unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def init() do
        :ets.new(@ets_table, [ :set, :protected, :named_table ])
      end

      def list,   do: :ets.tab2list(@ets_table)
      def local,  do: @file_local
      def remote, do: @file_remote
      def var,    do: @file_var

      def load(path) do
        map = Path.join(path, local)

        if File.regular?(map) do
          map
          |> unquote(__MODULE__).load_map()
          |> parse_map()
        end

        :ok
      end

      def parse_map([]),              do: :ok
      def parse_map([ entry | map ])  do
        store_entry(entry)
        parse_map(map)
      end

      def to_long(short) do
        list
        |> Enum.find({ short, short }, fn ({ s, _ }) -> short == s end)
        |> elem(1)
      end

      def to_short(long) do
        list
        |> Enum.find({ long, long }, fn ({ _, l }) -> long == l end)
        |> elem(0)
      end
    end
  end

  @doc """
  Initializes (sets up) the short code map.
  """
  @callback init() :: atom | :ets.tid

  @doc """
  Returns all short code map entries as a list.
  """
  @callback list() :: list

  @doc """
  Loads a short code map.
  """
  @callback load(path :: String.t) :: :ok

  @doc """
  Stores a mapping entry.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback store_entry(entry :: any) :: boolean

  @doc """
  Returns the long representation for a short name.

  Unknown names are returned unmodified.
  """
  @callback to_long(String.t) :: String.t

  @doc """
  Returns the short representation for a long name.

  Unknown names are returned unmodified.
  """
  @callback to_short(String.t) :: String.t

  @doc """
  Parses a yaml mapping file and returns the contents.
  """
  @spec load_map(String.t) :: any
  def load_map(file) do
    file
    |> to_char_list()
    |> :yamerl_constr.file([ :str_node_as_binary ])
    |> hd()
  end
end
