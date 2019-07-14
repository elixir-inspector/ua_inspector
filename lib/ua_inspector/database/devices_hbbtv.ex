defmodule UAInspector.Database.DevicesHbbTV do
  @moduledoc false

  use UAInspector.Database

  alias UAInspector.Config
  alias UAInspector.Util

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def sources do
    [{"", "device.televisions.yml", Config.database_url(:device, "televisions.yml")}]
  end

  def to_ets({brand, data}, type) do
    data = Enum.into(data, %{})
    models = parse_models(data)

    {
      Util.build_regex(data["regex"]),
      {
        brand,
        models,
        data["device"],
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
