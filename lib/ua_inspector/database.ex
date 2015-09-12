defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
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
        :ets.new(@ets_table, [ :ordered_set, :protected, :named_table ])
      end

      def list,    do: :ets.tab2list(@ets_table)
      def sources, do: @sources

      def load(path) do
        for { type, local, _remote } <- @sources do
          database = Path.join(path, local)

          if File.regular?(database) do
            database
            |> unquote(__MODULE__).load_database()
            |> parse_database(type)
          end
        end
      end

      def parse_database([],                  _type), do: :ok
      def parse_database([ entry | database ], type)  do
        store_entry(entry, type)
        parse_database(database, type)
      end
    end
  end

  @doc """
  Initializes (sets up) the database.
  """
  @callback init() :: atom | :ets.tid

  @doc """
  Returns all database entries as a list.
  """
  @callback list() :: list

  @doc """
  Loads a database file.
  """
  @callback load(path :: String.t) :: no_return

  @doc """
  Traverses the database and passes each entry to the storage function.
  """
  @callback parse_database(entries :: list, type :: String.t) :: :ok

  @doc """
  Returns the database sources.
  """
  @callback sources() :: list

  @doc """
  Stores a database entry.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback store_entry(entry :: any, type :: String.t) :: boolean

  @doc """
  Parses a yaml database file and returns the contents.
  """
  @spec load_database(String.t) :: any
  def load_database(file) do
    file
    |> :yamerl_constr.file([ :str_node_as_binary ])
    |> hd()
  end
end
