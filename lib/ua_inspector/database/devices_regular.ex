defmodule UAInspector.Database.DevicesRegular do
  @moduledoc false

  use UAInspector.Database,
    ets_prefix: :ua_inspector_db_devices_regular,
    type: :device

  alias UAInspector.Config
  alias UAInspector.Util

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

    %{
      brand: brand,
      models: models,
      device: data["device"],
      regex: Util.build_regex(data["regex"]),
      type: type
    }
  end

  defp parse_models(data) do
    device = data["device"]

    if data["model"] do
      [
        %{
          brand: nil,
          device: device,
          model: data["model"] || "",
          regex: Util.build_regex(data["regex"])
        }
      ]
    else
      Enum.map(data["models"], fn model ->
        model = Enum.into(model, %{})

        %{
          brand: model["brand"],
          device: model["device"] || device,
          model: model["model"] || "",
          regex: Util.build_regex(model["regex"])
        }
      end)
    end
  end
end
