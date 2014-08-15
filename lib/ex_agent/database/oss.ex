defmodule ExAgent.Database.Oss do
  @ets_counter :oss
  @ets_table   :ex_agent_oss
  @sources [
    { "oss.yml", "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/oss.yml" }
  ]

  def init() do
    :ets.new(@ets_table, [ :ordered_set, :protected, :named_table ])
  end

  def list(), do: :ets.tab2list(@ets_table)

  def load(path) do
    for file <- Dict.keys(@sources) do
      database = Path.join(path, file)

      if File.regular?(database) do
        load_database(database)
      end
    end
  end

  def sources(),   do: @sources
  def terminate(), do: :ets.delete(@ets_table)

  defp load_database(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
      |> parse_database()
  end

  defp parse_database([]), do: :ok
  defp parse_database([ entry | database ]) do
    store_entry(entry)
    parse_database(database)
  end

  defp store_entry(data) do
    counter = ExAgent.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})
    entry   = %{
      name:    data["name"],
      regex:   Regex.compile!(data["regex"]),
      version: data["version"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
