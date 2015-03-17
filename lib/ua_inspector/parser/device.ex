defmodule UAInspector.Parser.Device do
  @moduledoc """
  UAInspector device information parser.
  """

  use UAInspector.Parser

  alias UAInspector.Database.Devices
  alias UAInspector.Result
  alias UAInspector.Util

  @hbbtv Regex.compile!("HbbTV/([1-9]{1}(\.[0-9]{1}){1,2})", [ :caseless ])

  def parse(ua) do
    case Regex.match?(@hbbtv, ua) do
      true  -> parse_hbbtv(ua)
      false -> parse_regular(ua)
    end
  end


  defp parse(_,  [],                              _),   do: :unknown
  defp parse(ua, [{ _index, entry } | database ], type) do
    if type == entry.type && Regex.match?(entry.regex, ua) do
       parse_model(ua, entry, entry.models)
     else
      parse(ua, database, type)
    end
  end


  defp parse_hbbtv(ua) do
    case parse(ua, Devices.list, "hbbtv") do
      :unknown -> %Result.Device{ type: "tv" }
      device   -> device
    end
  end

  defp parse_regular(ua) do
    case parse(ua, Devices.list, "regular") do
      :unknown -> %Result.Device{ type: "desktop" }
      device   -> device
    end
  end


  defp parse_model(_,  _,      []),                do: :unknown
  defp parse_model(ua, device, [ model | models ]) do
    if Regex.match?(model.regex, ua) do
      parse_model_data(ua, device, model)
    else
      parse_model(ua, device, models)
    end
  end

  defp parse_model_data(ua, device, model) do
    captures  = Regex.run(model.regex, ua)
    model_str =
         (model.model || "")
      |> Util.uncapture(captures)
      |> Util.sanitize_model()
      |> Util.maybe_unknown()

    %Result.Device{
      brand: device.brand,
      type:  model.device,
      model: model_str
    }
  end
end
