defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
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
        ets_opts = [ :protected, :ordered_set ]

        ets_counter = :ets.new(__MODULE__.Counter, ets_opts)
        ets_tid     = :ets.new(__MODULE__, ets_opts)

        _ = :ets.insert(ets_counter, [ index: 0 ])

        { :ok, %State{ ets_counter: ets_counter, ets_tid: ets_tid }}
      end


      # GenServer callbacks

      def handle_call(:ets_tid, _from, state) do
        { :reply, state.ets_tid, state }
      end

      def handle_call({ :load, path }, _from, state) do
        for { type, local, _remote } <- sources do
          database = Path.join(path, local)

          if File.regular?(database) do
            database
            |> unquote(__MODULE__).load_database()
            |> parse_database(type, state)
          end
        end

        { :reply, :ok, state }
      end


      # Public methods

      def list, do: GenServer.call(__MODULE__, :ets_tid) |> :ets.tab2list()

      def load(path), do: GenServer.call(__MODULE__, { :load, path })

      def sources, do: unquote(opts[:sources])


      # Internal methods

      defp parse_database([ entry | database ], type, state)  do
        data  = entry |> to_ets(type)
        index = :ets.update_counter(state.ets_counter, :index, 1)
        _     = :ets.insert(state.ets_tid, { index, data })

        parse_database(database, type, state)
      end
      defp parse_database([], _, _), do: :ok
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
  Loads a database file.
  """
  @callback load(path :: String.t) :: :ok

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


  # Utility methods

  @doc """
  Parses a yaml database file and returns the contents.
  """
  @spec load_database(String.t) :: any
  def load_database(file) do
    file
    |> to_char_list()
    |> :yamerl_constr.file([ :str_node_as_binary ])
    |> hd()
  end
end
