defmodule UAInspector.Database.OSs do
  @moduledoc """
  UAInspector operating system information database.
  """

  @ets_table       :ua_inspector_database_oss
  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  use UAInspector.Database, [
    ets_counter: :ua_inspector_database_oss_counter,
    ets_table:   @ets_table,
    sources:     [{ "", "oss.yml", "#{ @source_base_url }/oss.yml" }]
  ]

  alias UAInspector.Util

  def store_entry(data, _type) do
    counter = increment_counter()
    data    = Enum.into(data, %{})

    entry = %{
      name:    data["name"],
      regex:   Util.build_regex(data["regex"]),
      version: data["version"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
