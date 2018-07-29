defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
  """

  defmacro __using__(opts) do
    quote do
      use UAInspector.Storage.Server

      require Logger

      alias UAInspector.Config
      alias UAInspector.Storage.State
      alias UAInspector.Util.YAML

      @behaviour unquote(__MODULE__)

      @drop_delay 30_000

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
        state = %State{ets_tid: create_ets_table()}

        :ok = load_sources(sources(), Config.database_path(), state.ets_tid)
        _ = Process.send_after(self(), {:drop_ets_table, old_ets_tid}, @drop_delay)

        {:noreply, state}
      end

      def handle_info({:drop_ets_table, nil}, state), do: {:noreply, state}

      def handle_info({:drop_ets_table, ets_tid}, state) do
        case state.ets_tid == ets_tid do
          true ->
            # ignore call!
            {:noreply, state}

          false ->
            :ok = drop_ets_table(ets_tid)
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

      defp create_ets_table() do
        ets_name = __MODULE__
        ets_opts = [:protected, :ordered_set, read_concurrency: true]

        :ets.new(ets_name, ets_opts)
      end

      defp drop_ets_table(ets_tid) do
        true =
          case :ets.info(ets_tid) do
            :undefined -> true
            _ -> :ets.delete(ets_tid)
          end

        :ok
      end

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
