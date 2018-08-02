defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
  """

  defmacro __using__(opts) do
    quote do
      use UAInspector.Storage.Server

      require Logger

      alias UAInspector.Config
      alias UAInspector.Storage.ETS
      alias UAInspector.Storage.State
      alias UAInspector.Util.YAML

      @behaviour unquote(__MODULE__)

      @ets_cleanup_delay_default 30_000

      # GenServer lifecycle

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

        :ok = load_sources(sources(), Config.database_path(), state.ets_tid)
        :ok = schedule_ets_cleanup(old_ets_tid)

        {:noreply, state}
      end

      def handle_info({:drop_ets_table, nil}, state), do: {:noreply, state}

      def handle_info({:drop_ets_table, ets_tid}, state) do
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

      def sources do
        Enum.map(unquote(opts[:sources]), fn {t, file} ->
          {
            t,
            "#{unquote(opts[:type])}.#{file}",
            Config.database_url(unquote(opts[:type]), file)
          }
        end)
      end

      # Internal methods

      defp load_sources(sources, path, ets_tid) do
        _ =
          Enum.reduce(sources, 0, fn {type, local, _remote}, acc_index ->
            database = Path.join(path, local)

            case File.regular?(database) do
              false ->
                Logger.info("failed to load database: #{database}")
                acc_index

              true ->
                database
                |> YAML.read_file()
                |> parse_database(type, ets_tid, acc_index)
            end
          end)

        :ok
      end

      defp parse_database([entry | database], type, ets_tid, index) do
        data = to_ets(entry, type)
        _ = :ets.insert(ets_tid, {index, data})

        parse_database(database, type, ets_tid, index + 1)
      end

      defp parse_database([], _, _ets_tid, index), do: index

      defp schedule_ets_cleanup(ets_tid) do
        Process.send_after(
          self(),
          {:drop_ets_table, ets_tid},
          Config.get(:ets_cleanup_delay, @ets_cleanup_delay_default)
        )

        :ok
      end
    end
  end

  # Public methods

  @doc """
  Returns the database sources.
  """
  @callback sources() :: list

  # Internal methods

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any, type :: String.t()) :: term
end
