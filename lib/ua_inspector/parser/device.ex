defmodule UAInspector.Parser.Device do
  @moduledoc """
  UAInspector device information parser.
  """

  use UAInspector.Parser

  alias UAInspector.Database.Devices
  alias UAInspector.Parser.VendorFragment
  alias UAInspector.Result
  alias UAInspector.Util

  @hbbtv          Util.build_regex("HbbTV/([1-9]{1}(\.[0-9]{1}){1,2})")
  @android_mobile Util.build_regex("Android; Mobile;")
  @android_tablet Util.build_regex("Android; Tablet;")

  def parse(ua) do
    device = case Regex.match?(@hbbtv, ua) do
      true  -> parse_hbbtv(ua)
      false -> parse_regular(ua)
    end

    device
    |> maybe_parse_type(ua, @android_mobile, "smartphone")
    |> maybe_parse_type(ua, @android_tablet, "tablet")
    |> maybe_parse_vendor(ua)
  end


  defp maybe_no_model(:unknown, device) do
    %Result.Device{
      brand: device.brand,
      type:  device.device || :unknown
    }
  end

  defp maybe_no_model(result, _), do: result


  defp maybe_parse_type(%{ type: :unknown } = device, ua, regex, type) do
    if Regex.match?(regex, ua) do
      %{ device | type: type }
    else
      device
    end
  end

  defp maybe_parse_type(device, _, _, _), do: device

  defp maybe_parse_vendor(%{ brand: :unknown } = device, ua) do
    %{ device | brand: VendorFragment.parse(ua) }
  end

  defp maybe_parse_vendor(device, _), do: device


  defp parse(_,  [],                              _),   do: :unknown
  defp parse(ua, [{ _index, entry } | database ], type) do
    if type == entry.type && Regex.match?(entry.regex, ua) do
      ua
      |> parse_model(entry, entry.models)
      |> maybe_no_model(entry)
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
      :unknown -> %Result.Device{}
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

    brand_str = (model.brand || device.brand) |> Util.maybe_unknown

    %Result.Device{
      brand: brand_str,
      type:  model.device,
      model: model_str
    }
  end
end
