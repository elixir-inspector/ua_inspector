defmodule UAInspector.Storage.Server do
  @moduledoc """
  Base behaviour for all storage processes.
  """

  defmacro __using__(opts) do
    quote do
      use GenServer

      require Logger

      alias UAInspector.Config
      alias UAInspector.Storage.ETS

      @behaviour unquote(__MODULE__)

      @ets_cleanup_delay_default 30_000
      @ets_data_table_name :"#{unquote(opts[:ets_prefix])}_data"
      @ets_lookup_table_name :"#{unquote(opts[:ets_prefix])}_lookup"

      # GenServer lifecycle

      def start_link(default \\ %{}) do
        GenServer.start_link(__MODULE__, default, name: __MODULE__)
      end

      def init(state) do
        :ok = GenServer.cast(__MODULE__, :reload)

        {:ok, state}
      end

      # GenServer callbacks

      def handle_info({:drop_data_table, nil}, state), do: {:noreply, state}

      def handle_info({:drop_data_table, ets_tid}, state) do
        :ok = ETS.delete(ets_tid)

        {:noreply, state}
      end

      def handle_cast(:reload, state) do
        @ets_lookup_table_name = ETS.create_lookup(@ets_lookup_table_name)
        old_ets_tid = ETS.fetch_data(@ets_lookup_table_name, @ets_data_table_name)
        new_ets_tid = ETS.create_data(@ets_data_table_name)

        _ =
          if Config.database_path() do
            :ok = do_reload(new_ets_tid)
          else
            _ = Logger.warn("Reload error: no database path configured")
          end

        :ok = schedule_data_cleanup(old_ets_tid)
        :ok = ETS.update_data(@ets_lookup_table_name, @ets_data_table_name, new_ets_tid)

        {:noreply, state}
      end

      # Public methods

      def list do
        case ETS.fetch_data(@ets_lookup_table_name, @ets_data_table_name) do
          nil -> []
          ets_tid -> :ets.tab2list(ets_tid)
        end
      end

      # Internal methods

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

  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @callback start_link() :: GenServer.on_start()

  # Public methods

  @doc """
  Returns all database entries as a list.
  """
  @callback list() :: list
end
