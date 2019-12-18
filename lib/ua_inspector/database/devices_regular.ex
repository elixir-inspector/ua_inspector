defmodule UAInspector.Database.DevicesRegular do
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
      {"", "device.consoles.yml", Config.database_url(:device, "consoles.yml")},
      {"", "device.car_browsers.yml", Config.database_url(:device, "car_browsers.yml")},
      {"", "device.cameras.yml", Config.database_url(:device, "cameras.yml")},
      {"", "device.portable_media_player.yml",
       Config.database_url(:device, "portable_media_player.yml")},
      {"", "device.mobiles.yml", Config.database_url(:device, "mobiles.yml")}
    ]
  end

  def to_ets({brand, data}, type) do
    data = Enum.into(data, %{})
    models = parse_models(data)

    {
      Util.build_regex(data["regex"]),
      {
        brand,
        models,
        data["device"] || :unknown,
        type
      }
    }
  end

  defp parse_models(data) do
    device = data["device"]

    if data["model"] do
      [
        {
          Util.build_regex(data["regex"]),
          {
            nil,
            device,
            data["model"] || ""
          }
        }
      ]
    else
      Enum.map(data["models"], fn model ->
        model = Enum.into(model, %{})

        {
          Util.build_regex(model["regex"]),
          {
            model["brand"],
            model["device"] || device,
            model["model"] || ""
          }
        }
      end)
    end
  end
end
