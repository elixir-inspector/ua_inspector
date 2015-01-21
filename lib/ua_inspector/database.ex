defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
  """

  use Behaviour

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

      def list(),      do: :ets.tab2list(@ets_table)
      def sources(),   do: @sources
      def terminate(), do: :ets.delete(@ets_table)

      def load(path) do
        for file <- Dict.keys(@sources) do
          database = Path.join(path, file)

          if File.regular?(database) do
            database
              |> unquote(__MODULE__).load_database()
              |> parse_database()
          end
        end
      end

      def parse_database([]), do: :ok
      def parse_database([ entry | database ]) do
        store_entry(entry)
        parse_database(database)
      end
    end
  end

  @doc """
  Initializes (sets up) the database.
  """
  defcallback init() :: atom | :ets.tid

  @doc """
  Returns all database entries as a list.
  """
  defcallback list() :: list

  @doc """
  Loads a database file.
  """
  defcallback load(String.t) :: no_return

  @doc """
  Traverses the database and passes each entry to the storage function.
  """
  defcallback parse_database(list) :: :ok

  @doc """
  Returns the database sources.
  """
  defcallback sources() :: list

  @doc """
  Stores a database entry.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  defcallback store_entry(any) :: boolean

  @doc """
  Terminates (deletes) the database.
  """
  defcallback terminate() :: :true

  @doc """
  Parses a yaml database file and returns the contents.
  """
  @spec load_database(String.t) :: any
  def load_database(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
  end
end
