defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
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
        ets_opts = [ :ordered_set, :protected, :named_table ]

        _ = :ets.new(unquote(opts[:ets_counter]), ets_opts)
        _ = :ets.new(unquote(opts[:ets_table]), ets_opts)

        _ = :ets.insert(unquote(opts[:ets_counter]), [ index: 0 ])

        { :ok, %{} }
      end


      # GenServer callbacks

      def handle_call({ :load, path }, _from, state) do
        for { type, local, _remote } <- sources do
          database = Path.join(path, local)

          if File.regular?(database) do
            database
            |> unquote(__MODULE__).load_database()
            |> parse_database(type)
          end
        end

        { :reply, :ok, state }
      end


      # Public methods

      def load(path), do: GenServer.call(__MODULE__, { :load, path })

      def list,    do: :ets.tab2list(unquote(opts[:ets_table]))
      def sources, do: unquote(opts[:sources])


      # Internal methods

      defp parse_database([],                  _type), do: :ok
      defp parse_database([ entry | database ], type)  do
        store_entry(entry, type)
        parse_database(database, type)
      end

      defp increment_counter() do
        :ets.update_counter(unquote(opts[:ets_counter]), :index, 1)
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
  Stores a database entry.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback store_entry(entry :: any, type :: String.t) :: boolean


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
