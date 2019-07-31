defmodule UAInspector.Database.Clients do
  @moduledoc false

  use UAInspector.Database

  alias UAInspector.Config
  alias UAInspector.Util

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

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

    {
      Util.build_regex(data["regex"]),
      {
        prepare_engine_data(type, data["engine"]),
        data["name"] || "",
        type,
        to_string(data["version"] || "")
      }
    }
  end

  defp prepare_engine_data("browser", [{"default", default}, {"versions", non_default}]) do
    non_default =
      non_default
      |> Enum.map(fn {version, name} ->
        {version |> to_string() |> Util.to_semver(), name}
      end)
      |> Enum.reverse()

    [{"default", default}, {"versions", non_default}]
  end

  defp prepare_engine_data(_, engine_data), do: engine_data
end
