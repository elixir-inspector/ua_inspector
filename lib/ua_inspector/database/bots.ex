defmodule UAInspector.Database.Bots do
  @moduledoc """
  UAInspector bot information database.
  """

  @ets_table       :ua_inspector_database_bots
  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  use UAInspector.Database, [
    ets_table: @ets_table,
    sources:   [{ "", "bots.yml", "#{ @source_base_url }/bots.yml" }]
  ]

  alias UAInspector.Util

  def store_entry(data, _type) do
    counter = UAInspector.Databases.update_counter(:bots)
    data    = Enum.into(data, %{})

    entry = %{
      category: data["category"],
      name:     data["name"],
      producer: producer_info(data["producer"]),
      regex:    Util.build_regex(data["regex"]),
      url:      data["url"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end

  defp producer_info(nil), do: nil
  defp producer_info(info) do
    info = Enum.into(info, %{})

    %{ name: info["name"], url: info["url"] }
  end
end
