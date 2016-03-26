defmodule UAInspector.ShortCodeMap do
  @moduledoc """
  Basic short code map module providing minimal functions.
  """

  defmacro __using__(opts) do
    quote do
      use GenServer

      alias UAInspector.Config
      alias UAInspector.Util.YAML

      alias unquote(__MODULE__).State

      @behaviour unquote(__MODULE__)


      # GenServer lifecycle

      def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
      end

      def init(_) do
        ets_opts = [ :protected, :set, read_concurrency: true ]
        ets_tid  = :ets.new(__MODULE__, ets_opts)

        state = %State{ ets_tid: ets_tid }
        state = load_map(state)

        { :ok, state }
      end


      # GenServer callbacks

      def handle_call(:ets_tid, _from, state) do
        { :reply, state.ets_tid, state }
      end


      # Public methods

      def list, do: GenServer.call(__MODULE__, :ets_tid) |> :ets.tab2list()

      def file_local,  do: unquote(opts[:file_local])
      def file_remote, do: unquote(opts[:file_remote])
      def var_name,    do: unquote(opts[:var_name])

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

      defp load_map(state) do
        map = Config.database_path |> Path.join(file_local)

        case File.regular?(map) do
          false -> state
          true  ->
            map
            |> YAML.read_file()
            |> parse_map(state)
        end
      end

      defp parse_map([ entry | map ], state)  do
        data = entry |> to_ets()
        _    = :ets.insert(state.ets_tid, data)

        parse_map(map, state)
      end
      defp parse_map([], state), do: state
    end
  end


  # GenServer lifecycle

  @doc """
  Starts the short code map server.
  """
  @callback start_link() :: GenServer.on_start


  # Public methods

  @doc """
  Returns the local filename for this map.
  """
  @callback file_local() :: String.t

  @doc """
  Returns the remote path for this map.
  """
  @callback file_remote() :: String.t

  @doc """
  Returns all short code map entries as a list.
  """
  @callback list() :: list

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
  @callback var_name() :: String.t


  # Internal methods

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any) :: term
end
