defmodule UAInspector.ShortCodeMap do
  @moduledoc """
  Basic short code map module providing minimal functions.
  """

  defmacro __using__(opts) do
    quote do
      use GenServer

      @behaviour unquote(__MODULE__)


      # GenServer lifecycle

      def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
      end

      def init(_) do
        ets_table = unquote(opts[:ets_table])
        ets_opts  = [ :set, :protected, :named_table ]

        _ = :ets.new(ets_table, ets_opts)

        { :ok, %{} }
      end


      # GenServer callbacks

      def handle_call({ :load, path }, _from, state) do
        map = Path.join(path, local)

        if File.regular?(map) do
          map
          |> unquote(__MODULE__).load_map()
          |> parse_map()
        end

        { :reply, :ok, state }
      end


      # Public methods

      def load(path), do: GenServer.call(__MODULE__, { :load, path })

      def list,   do: :ets.tab2list(unquote(opts[:ets_table]))
      def local,  do: unquote(opts[:file_local])
      def remote, do: unquote(opts[:file_remote])
      def var,    do: unquote(opts[:file_var])

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


      # Internal methods

      defp parse_map([]),              do: :ok
      defp parse_map([ entry | map ])  do
        store_entry(entry)
        parse_map(map)
      end
    end
  end


  # GenServer lifecycle

  @doc """
  Starts the short code map server.
  """
  @callback start_link() :: GenServer.on_start


  # Public methods

  @doc """
  Returns all short code map entries as a list.
  """
  @callback list() :: list

  @doc """
  Loads a short code map.
  """
  @callback load(path :: String.t) :: :ok

  @doc """
  Returns the local filename for this map.
  """
  @callback local() :: String.t

  @doc """
  Returns the remote path for this map.
  """
  @callback remote() :: String.t

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
  Returns a name representation for this map.
  """
  @callback var() :: String.t


  # Internal methods

  @doc """
  Stores a mapping entry.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback store_entry(entry :: any) :: boolean


  # Utility methods

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
