defmodule UAInspector.Database.Clients do
  @moduledoc """
  UAInspector client information database.
  """

  use UAInspector .Database

  @ets_counter :clients
  @ets_table   :ua_inspector_clients
  @sources [
    { "clients.browsers.yml",     "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client/browsers.yml" },
    { "clients.feed_readers.yml", "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client/feed_readers.yml" },
    { "clients.libraries.yml",    "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client/libraries.yml" },
    { "clients.mediaplayers.yml", "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client/mediaplayers.yml" },
    { "clients.mobile_apps.yml",  "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client/mobile_apps.yml" },
    { "clients.pim.yml",          "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client/pim.yml" }
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
