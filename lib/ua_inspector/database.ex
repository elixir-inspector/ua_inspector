defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
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
        ets_opts = [ :protected, :ordered_set, read_concurrency: true ]
        ets_tid  = :ets.new(__MODULE__, ets_opts)

        state = %State{ ets_tid: ets_tid }
        state = load_sources(sources, Config.database_path, state)

        { :ok, state }
      end


      # GenServer callbacks

      def handle_call(:ets_tid, _from, state) do
        { :reply, state.ets_tid, state }
      end


      # Public methods

      def list, do: GenServer.call(__MODULE__, :ets_tid) |> :ets.tab2list()

      def sources, do: unquote(opts[:sources])


      # Internal methods

      defp load_sources([{ type, local, _remote } | sources ], path, state) do
        database = Path.join(path, local)

        if File.regular?(database) do
          state =
               database
            |> YAML.read_file()
            |> parse_database(type, state)
        end

        load_sources(sources, path, state)
      end
      defp load_sources([], _, state), do: state

      defp parse_database([ entry | database ], type, state)  do
        data  = entry |> to_ets(type)
        index = state.ets_index + 1
        _     = :ets.insert(state.ets_tid, { index, data })

        parse_database(database, type, %{ state | ets_index: index })
      end
      defp parse_database([], _, state), do: state
    end
  end

  # GenServer lifecycle

  @doc """
  Starts the short code map server.
  """
  @callback start_link() :: GenServer.on_start


  # Public methods

  @doc """
  Returns all database entries as a list.
  """
  @callback list() :: list

  @doc """
  Returns the database sources.
  """
  @callback sources() :: list


  # Internal methods

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any, type :: String.t) :: term
end
