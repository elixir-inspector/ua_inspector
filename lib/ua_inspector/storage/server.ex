defmodule UAInspector.Storage.Server do
  @moduledoc """
  Base behaviour for all storage processes.
  """

  defmacro __using__(_opts) do
    quote do
      use GenServer

      @behaviour unquote(__MODULE__)


      # GenServer lifecycle

      def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
      end


      # Public methods

      def list, do: GenServer.call(__MODULE__, :ets_tid) |> :ets.tab2list()
    end
  end


  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @callback start_link() :: GenServer.on_start


  # Public methods

  @doc """
  Returns all database entries as a list.
  """
  @callback list() :: list
end
