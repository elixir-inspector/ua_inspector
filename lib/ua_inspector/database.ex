defmodule UAInspector.Database do
  @moduledoc """
  Basic database module providing minimal functions.
  """

  defmacro __using__(opts) do
    quote do
      use UAInspector.Storage.Server, ets_prefix: unquote(opts[:ets_prefix])

      require Logger

      alias UAInspector.Config
      alias UAInspector.Util.YAML

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
