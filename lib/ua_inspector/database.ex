defmodule UAInspector.Database do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use UAInspector.Storage.Server, ets_prefix: unquote(opts[:ets_prefix])

      require Logger

      alias UAInspector.Config
      alias UAInspector.Storage.ETS
      alias UAInspector.Util.YAML

      defp do_reload(ets_tid) do
        _ =
          Enum.reduce(sources(), 0, fn {type, local, _remote}, acc_index ->
            database = Config.database_path() |> Path.join(local)

            case File.regular?(database) do
              false ->
                _ = Logger.info("failed to load database: #{database}")
                acc_index

              true ->
                database
                |> YAML.read_file()
                |> Enum.map(&to_ets(&1, type))
                |> ETS.store_data_entries(ets_tid, acc_index)
            end
          end)

        :ok
      end
    end
  end

  # Public methods

  @doc """
  Returns the database sources.
  """
  @callback sources() :: [{binary, binary, binary}]

  # Internal methods

  @doc """
  Converts a raw entry to its ets representation.

  If necessary a data conversion is made from the raw data passed
  directly out of the database file and the actual data needed when
  querying the database.
  """
  @callback to_ets(entry :: any, type :: String.t()) :: term
end
