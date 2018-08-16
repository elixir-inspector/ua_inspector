defmodule UAInspector.Storage.Server do
  @moduledoc """
  Base behaviour for all storage processes.
  """

  defmacro __using__(_opts) do
    quote do
      use GenServer

      alias UAInspector.Config
      alias UAInspector.Storage.ETS
      alias UAInspector.Storage.State

      @behaviour unquote(__MODULE__)

      @ets_cleanup_delay_default 30_000

      # GenServer lifecycle

      def start_link() do
        GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
      end

      def init(_) do
        :ok = GenServer.cast(__MODULE__, :reload)

        {:ok, %State{}}
      end

      # GenServer callbacks

      def handle_call(:ets_tid, _from, state) do
        {:reply, state.ets_tid, state}
      end

      def handle_cast(:reload, %State{ets_tid: old_ets_tid}) do
        state = %State{ets_tid: ETS.create(__MODULE__)}

        :ok = load(state.ets_tid)
        :ok = schedule_ets_cleanup(old_ets_tid)

        {:noreply, state}
      end

      def handle_info({:delete_ets_table, nil}, state), do: {:noreply, state}

      def handle_info({:delete_ets_table, ets_tid}, state) do
        case state.ets_tid == ets_tid do
          true ->
            # ignore call!
            {:noreply, state}

          false ->
            :ok = ETS.delete(ets_tid)
            {:noreply, state}
        end
      end

      # Public methods

      def list, do: GenServer.call(__MODULE__, :ets_tid) |> :ets.tab2list()

      # Internal methods

      defp schedule_ets_cleanup(ets_tid) do
        Process.send_after(
          self(),
          {:delete_ets_table, ets_tid},
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
