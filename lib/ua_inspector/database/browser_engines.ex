defmodule UAInspector.Database.BrowserEngines do
  @moduledoc """
  UAInspector browser engine information database.
  """

  use UAInspector.Database

  alias UAInspector.Util

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client"
  @sources         [{ "", "browser_engines.yml", "#{ @source_base_url }/browser_engine.yml" }]

  @ets_counter :browser_engines
  @ets_table   :ua_inspector_database_browser_engines

  def store_entry(data, _type) do
    counter = UAInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})

    entry = %{
      name:  data["name"],
      regex: Util.build_regex(data["regex"])
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
