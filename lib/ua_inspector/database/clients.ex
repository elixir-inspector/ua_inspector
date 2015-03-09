defmodule UAInspector.Database.Clients do
  @moduledoc """
  UAInspector client information database.
  """

  use UAInspector .Database

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client"

  @ets_counter :clients
  @ets_table   :ua_inspector_clients
  @sources [
    { "browser",     "clients.browsers.yml",     "#{ @source_base_url }/browsers.yml" },
    { "feed reader", "clients.feed_readers.yml", "#{ @source_base_url }/feed_readers.yml" },
    { "library",     "clients.libraries.yml",    "#{ @source_base_url }/libraries.yml" },
    { "mediaplayer", "clients.mediaplayers.yml", "#{ @source_base_url }/mediaplayers.yml" },
    { "mobile app",  "clients.mobile_apps.yml",  "#{ @source_base_url }/mobile_apps.yml" },
    { "pim",         "clients.pim.yml",          "#{ @source_base_url }/pim.yml" }
  ]

  def store_entry(data, type) do
    counter = UAInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})
    entry   = %{
      name:    data["name"],
      regex:   Regex.compile!(data["regex"], [ :caseless ]),
      type:    type,
      version: data["version"] |> to_string()
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
