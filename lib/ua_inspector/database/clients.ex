defmodule UAInspector.Database.Clients do
  @moduledoc """
  UAInspector client information database.
  """

  use UAInspector.Database, [
    sources: [
      # files ordered according to
      # https://github.com/piwik/device-detector/blob/master/DeviceDetector.php
      # to prevent false detections
      { "feed reader", "feed_readers.yml" },
      { "mobile app",  "mobile_apps.yml" },
      { "mediaplayer", "mediaplayers.yml" },
      { "pim",         "pim.yml" },
      { "browser",     "browsers.yml" },
      { "library",     "libraries.yml" }
    ],
    type: :client
  ]

  alias UAInspector.Util

  def to_ets(data, type) do
    data = Enum.into(data, %{})

    %{
      engine:  data["engine"],
      name:    data["name"],
      regex:   Util.build_regex(data["regex"]),
      type:    type,
      version: data["version"] |> to_string()
    }
  end
end
