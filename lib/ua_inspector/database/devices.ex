defmodule UAInspector.Database.Devices do
  @moduledoc """
  UAInspector device information database.
  """

  use UAInspector.Database

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device"

  @ets_counter :devices
  @ets_table   :ua_inspector_devices
  @sources [
    { "", "devices.cameras.yml",               "#{ @source_base_url }/cameras.yml" },
    { "", "devices.car_browsers.yml",          "#{ @source_base_url }/car_browsers.yml" },
    { "", "devices.consoles.yml",              "#{ @source_base_url }/consoles.yml" },
    { "", "devices.mobiles.yml",               "#{ @source_base_url }/mobiles.yml" },
    { "", "devices.portable_media_player.yml", "#{ @source_base_url }/portable_media_player.yml" },
    { "", "devices.televisions.yml",           "#{ @source_base_url }/televisions.yml" }
  ]

  def store_entry({ brand, data }, _type) do
    counter = UAInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})
    models  = parse_models(data)

    entry = %{
      brand:  brand,
      models: models,
      regex:  Regex.compile!(data["regex"])
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end

  defp parse_models(data) do
    device = data["device"]

    if data["model"] do
      [ %{ device: device, model: data["model"], regex: Regex.compile!(".*") } ]
    else
      Enum.map(data["models"], fn(model) ->
        model = Enum.into(model, %{})

        %{
          device: model["device"] || device,
          model:  model["model"],
          regex:  Regex.compile!(model["regex"])
        }
      end)
    end
  end
end
