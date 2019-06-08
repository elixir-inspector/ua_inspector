defmodule UAInspector.Storage.Server do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      use GenServer

      require Logger

      alias UAInspector.Config
      alias UAInspector.Storage.ETS

      @behaviour unquote(__MODULE__)

      @ets_cleanup_delay_default 30_000
      @ets_data_table_name __MODULE__.Data
      @ets_lookup_table_name __MODULE__.Lookup

      def init(_init_arg) do
        if Config.get(:startup_sync, false) do
          :ok = reload_databases()
        else
          :ok = GenServer.cast(__MODULE__, :reload)
        end

        {:ok, nil}
      end

      def handle_info({:drop_data_table, nil}, state), do: {:noreply, state}

      def handle_info({:drop_data_table, ets_tid}, state) do
        :ok = ETS.delete(ets_tid)

        {:noreply, state}
      end

      def handle_cast(:reload, state) do
        :ok = reload_databases()

        {:noreply, state}
      end

      def list do
        case ETS.fetch_data(@ets_lookup_table_name, @ets_data_table_name) do
          nil -> []
          ets_tid -> :ets.tab2list(ets_tid)
        end
      end

      defp reload_databases do
        @ets_lookup_table_name = ETS.create_lookup(@ets_lookup_table_name)
        old_ets_tid = ETS.fetch_data(@ets_lookup_table_name, @ets_data_table_name)
        new_ets_tid = ETS.create_data(@ets_data_table_name)

        :ok = ETS.store_data_entries(read_database(), new_ets_tid)
        :ok = schedule_data_cleanup(old_ets_tid)
        :ok = ETS.update_data(@ets_lookup_table_name, @ets_data_table_name, new_ets_tid)

        :ok
      end

      defp schedule_data_cleanup(ets_tid) do
        Process.send_after(
          self(),
          {:drop_data_table, ets_tid},
          Config.get(:ets_cleanup_delay, @ets_cleanup_delay_default)
        )

        :ok
      end
    end
  end

  @doc """
  Returns all database entries as a list.
  """
  @callback list() :: list
end
