defmodule UAInspector.Database.OSs do
  @moduledoc """
  UAInspector operating system information database.
  """

  use UAInspector.Database

  @ets_counter :oss
  @ets_table   :ua_inspector_oss
  @sources [
    { "oss.yml", "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/oss.yml" }
  ]

  def store_entry(data) do
    counter = UAInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})
    entry   = %{
      name:    data["name"],
      regex:   Regex.compile!(data["regex"]),
      version: data["version"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
