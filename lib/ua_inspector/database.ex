defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
  """

  defmacro __using__(opts) do
    quote do
      @behaviour unquote(__MODULE__)

      def init() do
        :ets.new(
          unquote(opts[:ets_table]),
          [ :ordered_set, :protected, :named_table ]
        )
      end

      def list,    do: :ets.tab2list(unquote(opts[:ets_table]))
      def sources, do: unquote(opts[:sources])

      def load(path) do
        for { type, local, _remote } <- sources do
          database = Path.join(path, local)

          if File.regular?(database) do
            database
            |> unquote(__MODULE__).load_database()
            |> parse_database(type)
          end
        end

        :ok
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
  @callback load(path :: String.t) :: :ok

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
    |> to_char_list()
    |> :yamerl_constr.file([ :str_node_as_binary ])
    |> hd()
  end
end
