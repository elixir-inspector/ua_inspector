defmodule UAInspector.Database.Devices do
  @moduledoc """
  UAInspector device information database.
  """

  use UAInspector.Database,
    sources: [
      # files ordered according to
      # https://github.com/piwik/device-detector/blob/master/DeviceDetector.php
      # to prevent false detections
      {"hbbtv", "televisions.yml"},
      {"regular", "consoles.yml"},
      {"regular", "car_browsers.yml"},
      {"regular", "cameras.yml"},
      {"regular", "portable_media_player.yml"},
      {"regular", "mobiles.yml"}
    ],
    type: :device

  alias UAInspector.Util

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
          model: data["model"],
          regex: Util.build_regex(data["regex"])
        }
      ]
    else
      Enum.map(data["models"], fn model ->
        model = Enum.into(model, %{})

        %{
          brand: model["brand"],
          device: model["device"] || device,
          model: model["model"],
          regex: Util.build_regex(model["regex"])
        }
      end)
    end
  end
end
