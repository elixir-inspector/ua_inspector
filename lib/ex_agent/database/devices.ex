defmodule ExAgent.Database.Devices do
  @ets_counter :devices
  @ets_table   :ex_agent_devices
  @sources [
    { "devices.cameras.yml",      "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/cameras.yml" },
    { "devices.car_browsers.yml", "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/car_browsers.yml" },
    { "devices.consoles.yml",     "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/consoles.yml" },
    { "devices.mobiles.yml",      "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/mobiles.yml" },
    { "devices.televisions.yml",  "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/device/televisions.yml" }
  ]

  def init() do
    :ets.new(@ets_table, [ :ordered_set, :private, :named_table ])
  end

  def list(), do: :ets.tab2list(@ets_table)

  def load(path) do
    for file <- Dict.keys(@sources) do
      database = Path.join(path, file)

      if File.regular?(database) do
        load_database(database)
      end
    end
  end

  def sources(),   do: @sources
  def terminate(), do: :ets.delete(@ets_table)

  defp load_database(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
      |> parse_database()
  end

  defp parse_database([]), do: :ok
  defp parse_database([ { brand, entry } | database ]) do
    store_entry(brand, entry)
    parse_database(database)
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

  defp store_entry(brand, data) do
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
end
