defmodule UAInspector.Storage.Server do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use GenServer

      alias UAInspector.Config

      @behaviour unquote(__MODULE__)

      @ets_table_name __MODULE__
      @ets_table_opts [:named_table, :protected, :set, read_concurrency: true]

      @impl GenServer
      def init(_init_arg) do
        :ok =
          if Config.get(:startup_sync, true) do
            reload_database()
          else
            GenServer.cast(__MODULE__, :reload)
          end

        {:ok, nil}
      end

      @impl GenServer
      def handle_call(:reload, _from, state) do
        {:reply, reload_database(), state}
      end

      @impl GenServer
      def handle_cast(:reload, state) do
        :ok = reload_database()

        {:noreply, state}
      end

      @impl unquote(__MODULE__)
      def list do
        case :ets.lookup(@ets_table_name, :data) do
          [{:data, entries}] -> entries
          _ -> []
        end
      rescue
        _ -> []
      end

      defp create_ets_table do
        case :ets.info(@ets_table_name) do
          :undefined ->
            _ = :ets.new(@ets_table_name, @ets_table_opts)
            :ok

          _ ->
            :ok
        end
      end

      defp reload_database do
        datasets = read_database()

        :ok = create_ets_table()
        true = :ets.insert(@ets_table_name, {:data, datasets})

        :ok
      end
    end
  end

  @doc """
  Returns all database entries as a list.
  """
  @callback list() :: list
end
