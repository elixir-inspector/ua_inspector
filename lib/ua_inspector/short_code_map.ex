defmodule UAInspector.ShortCodeMap do
  @moduledoc """
  Basic short code map module providing minimal functions.
  """

  defmacro __using__(opts) do
    quote do
      use GenServer

      alias unquote(__MODULE__).State

      @behaviour unquote(__MODULE__)


      # GenServer lifecycle

      def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
      end

      def init(_) do
        ets_tid = :ets.new(__MODULE__, [ :protected, :set ])

        { :ok, %State{ ets_tid: ets_tid }}
      end


      # GenServer callbacks

      def handle_call(:ets_tid, _from, state) do
        { :reply, state.ets_tid, state }
      end

      def handle_call({ :load, path }, _from, state) do
        map = Path.join(path, local)

        if File.regular?(map) do
          map
          |> unquote(__MODULE__).load_map()
          |> parse_map(state)
        end

        { :reply, :ok, state }
      end


      # Public methods

      def list, do: GenServer.call(__MODULE__, :ets_tid) |> :ets.tab2list()

      def load(path), do: GenServer.call(__MODULE__, { :load, path })

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

      defp parse_map([ entry | map ], state)  do
        data = entry |> to_ets()
        _    = :ets.insert(state.ets_tid, data)

        parse_map(map, state)
      end
      defp parse_map([], _), do: :ok
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
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any) :: term


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
