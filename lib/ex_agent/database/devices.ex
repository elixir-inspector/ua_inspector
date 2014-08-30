defmodule ExAgent.Database.Devices do
  @moduledoc """
  ExAgent device information database.
  """

  use ExAgent.Database

  @ets_counter :devices
  @ets_table   :ex_agent_devices
  @sources [
    { "devices.cameras.yml",      "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/cameras.yml" },
    { "devices.car_browsers.yml", "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/car_browsers.yml" },
    { "devices.consoles.yml",     "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/consoles.yml" },
    { "devices.mobiles.yml",      "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/mobiles.yml" },
    { "devices.televisions.yml",  "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/televisions.yml" }
  ]

  def store_entry({ brand, data }) do
    counter = ExAgent.Databases.update_counter(@ets_counter)
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
