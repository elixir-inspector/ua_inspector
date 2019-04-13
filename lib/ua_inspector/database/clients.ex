defmodule UAInspector.Database.Clients do
  @moduledoc false

  use UAInspector.Database,
    ets_prefix: :ua_inspector_db_clients,
    type: :client

  alias UAInspector.Config
  alias UAInspector.Util

  def sources do
    # files ordered according to
    # https://github.com/matomo-org/device-detector/blob/master/DeviceDetector.php
    # to prevent false detections
    [
      {"feed reader", "client.feed_readers.yml",
       Config.database_url(:client, "feed_readers.yml")},
      {"mobile app", "client.mobile_apps.yml", Config.database_url(:client, "mobile_apps.yml")},
      {"mediaplayer", "client.mediaplayers.yml",
       Config.database_url(:client, "mediaplayers.yml")},
      {"pim", "client.pim.yml", Config.database_url(:client, "pim.yml")},
      {"browser", "client.browsers.yml", Config.database_url(:client, "browsers.yml")},
      {"library", "client.libraries.yml", Config.database_url(:client, "libraries.yml")}
    ]
  end

  def to_ets(data, type) do
    data = Enum.into(data, %{})

    %{
      engine: data["engine"],
      name: data["name"] || "",
      regex: Util.build_regex(data["regex"]),
      type: type,
      version: to_string(data["version"]) || ""
    }
  end
end
