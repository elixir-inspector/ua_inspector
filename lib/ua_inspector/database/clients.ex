defmodule UAInspector.Database.Clients do
  @moduledoc """
  UAInspector client information database.
  """

  @ets_table       :ua_inspector_database_clients
  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client"

  use UAInspector.Database, [
    ets_counter: :ua_inspector_database_clients_counter,
    ets_table:   @ets_table,
    sources:     [
      # files ordered according to
      # https://github.com/piwik/device-detector/blob/master/DeviceDetector.php
      # to prevent false detections
      { "feed reader", "clients.feed_readers.yml", "#{ @source_base_url }/feed_readers.yml" },
      { "mobile app",  "clients.mobile_apps.yml",  "#{ @source_base_url }/mobile_apps.yml" },
      { "mediaplayer", "clients.mediaplayers.yml", "#{ @source_base_url }/mediaplayers.yml" },
      { "pim",         "clients.pim.yml",          "#{ @source_base_url }/pim.yml" },
      { "browser",     "clients.browsers.yml",     "#{ @source_base_url }/browsers.yml" },
      { "library",     "clients.libraries.yml",    "#{ @source_base_url }/libraries.yml" }
    ]
  ]

  alias UAInspector.Util

  def store_entry(data, type) do
    counter = increment_counter()
    data    = Enum.into(data, %{})

    entry = %{
      engine:  data["engine"],
      name:    data["name"],
      regex:   Util.build_regex(data["regex"]),
      type:    type,
      version: data["version"] |> to_string()
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
