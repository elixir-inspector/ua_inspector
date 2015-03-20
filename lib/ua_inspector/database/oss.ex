defmodule UAInspector.Database.OSs do
  @moduledoc """
  UAInspector operating system information database.
  """

  use UAInspector.Database

  alias UAInspector.Util

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  @ets_counter :oss
  @ets_table   :ua_inspector_oss
  @sources [{ "", "oss.yml", "#{ @source_base_url }/oss.yml" }]

  def store_entry(data, _type) do
    counter = UAInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})
    entry   = %{
      name:    data["name"],
      regex:   Util.build_regex(data["regex"]),
      version: data["version"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
