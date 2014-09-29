defmodule ExAgent.Database do
  @moduledoc """
  Basic database module providing minimal functions.
  """

  use Behaviour

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc """
      Initializes (sets up) the database.
      """
      @spec init() :: atom | :ets.tid
      def init() do
        :ets.new(@ets_table, [ :ordered_set, :protected, :named_table ])
      end

      @doc """
      Returns all database entries as a list.
      """
      @spec list() :: list
      def list(), do: :ets.tab2list(@ets_table)

      @doc """
      Loads a database file.
      """
      @spec load(String.t) :: no_return
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

      @doc """
      Returns the database sources.
      """
      @spec sources() :: list
      def sources(), do: @sources

      @doc """
      Terminates (deletes) the database.
      """
      @spec terminate() :: :true
      def terminate(), do: :ets.delete(@ets_table)

      @doc """
      Traverses the database and passes each entry to the storage function.
      """
      @spec parse_database(list) :: :ok
      def parse_database([]), do: :ok
      def parse_database([ entry | database ]) do
        store_entry(entry)
        parse_database(database)
      end
    end
  end

  @doc """
  Stores a database entry.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  defcallback store_entry(any) :: boolean

  @doc """
  Parses a yaml database file and returns the contents.
  """
  @spec load_database(String.t) :: any
  def load_database(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
  end
end
