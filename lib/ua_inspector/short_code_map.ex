defmodule UAInspector.ShortCodeMap do
  @moduledoc """
  Basic short code map module providing minimal functions.
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

      def handle_cast(:reload, %State{ets_tid: old_ets_tid} = state) do
        state = %State{ets_tid: ETS.create(__MODULE__)}

        :ok = load_map(state.ets_tid)
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

      def file_local, do: unquote(opts[:file_local])
      def file_remote, do: Config.database_url(:short_code_map, unquote(opts[:file_remote]))
      def var_name, do: unquote(opts[:var_name])
      def var_type, do: unquote(opts[:var_type])

      def to_long(short) do
        list()
        |> Enum.find({short, short}, fn {s, _} -> short == s end)
        |> elem(1)
      end

      def to_short(long) do
        list()
        |> Enum.find({long, long}, fn {_, l} -> long == l end)
        |> elem(0)
      end

      # Internal methods

      defp load_map(ets_tid) do
        map = Config.database_path() |> Path.join(file_local())

        case File.regular?(map) do
          false ->
            Logger.info("failed to load short code map: #{map}")
            :ok

          true ->
            map
            |> YAML.read_file()
            |> parse_map(ets_tid)
        end
      end

      defp parse_map([entry | map], ets_tid) do
        data = to_ets(entry)
        _ = :ets.insert(ets_tid, data)

        parse_map(map, ets_tid)
      end

      defp parse_map([], _ets_tid), do: :ok

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
  Returns the local filename for this map.
  """
  @callback file_local() :: String.t()

  @doc """
  Returns the remote path for this map.
  """
  @callback file_remote() :: String.t()

  @doc """
  Returns the long representation for a short name.

  Unknown names are returned unmodified.
  """
  @callback to_long(String.t()) :: String.t()

  @doc """
  Returns the short representation for a long name.

  Unknown names are returned unmodified.
  """
  @callback to_short(String.t()) :: String.t()

  @doc """
  Returns a name representation for this map.
  """
  @callback var_name() :: String.t()

  @doc """
  Returns a type representation for this map.
  """
  @callback var_type() :: :hash | :list

  # Internal methods

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any) :: term
end
