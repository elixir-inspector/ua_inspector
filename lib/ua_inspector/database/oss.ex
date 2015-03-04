defmodule UAInspector.Database.OSs do
  @moduledoc """
  UAInspector operating system information database.
  """

  use UAInspector.Database

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"

  @ets_counter :oss
  @ets_table   :ua_inspector_oss
  @sources [{ "", "oss.yml", "#{ @source_base_url }/oss.yml" }]

  def store_entry(data, _type) do
    counter = UAInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})
    entry   = %{
      name:    data["name"],
      regex:   Regex.compile!(data["regex"], [ :caseless ]),
      version: data["version"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
