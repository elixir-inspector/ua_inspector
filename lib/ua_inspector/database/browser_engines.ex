defmodule UAInspector.Database.BrowserEngines do
  @moduledoc """
  UAInspector browser engine information database.
  """

  @ets_table       :ua_inspector_database_browser_engines
  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client"

  use UAInspector.Database, [
    ets_counter: :ua_inspector_database_browser_engines_counter,
    ets_table:   @ets_table,
    sources:     [{ "", "browser_engines.yml", "#{ @source_base_url }/browser_engine.yml" }]
  ]

  alias UAInspector.Util

  def store_entry(data, _type) do
    counter = increment_counter()
    data    = Enum.into(data, %{})

    entry = %{
      name:  data["name"],
      regex: Util.build_regex(data["regex"])
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
