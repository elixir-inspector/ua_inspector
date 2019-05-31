defmodule UAInspector.Parser.Device do
  @moduledoc false

  alias UAInspector.Database.DevicesHbbTV
  alias UAInspector.Database.DevicesRegular
  alias UAInspector.Parser.VendorFragment
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  @hbbtv Util.build_regex("HbbTV/([1-9]{1}(?:\.[0-9]{1}){1,2})")
  @android_mobile Util.build_regex("Android( [\.0-9]+)?; Mobile;")
  @android_tablet Util.build_regex("Android( [\.0-9]+)?; Tablet;")
  @opera_tablet Util.build_regex("Opera Tablet")

  def parse(ua) do
    device =
      case Regex.match?(@hbbtv, ua) do
        true -> parse_hbbtv(ua)
        false -> parse_regular(ua)
      end

    device
    |> maybe_parse_type(ua, @android_mobile, "smartphone")
    |> maybe_parse_type(ua, @android_tablet, "tablet")
    |> maybe_parse_type(ua, @opera_tablet, "tablet")
    |> maybe_parse_vendor(ua)
  end

  @doc """
  Parses the version out of a (possible) HbbTV user agent.
  """
  @spec parse_hbbtv_version(String.t()) :: nil | String.t()
  def parse_hbbtv_version(ua) do
    case Regex.run(@hbbtv, ua) do
      nil -> nil
      captures -> List.last(captures)
    end
  end

  defp maybe_no_model(:unknown, device) do
    %Result.Device{
      brand: device.brand,
      type: device.device || :unknown
    }
  end

  defp maybe_no_model(result, _), do: result

  defp maybe_parse_type(%{type: :unknown} = device, ua, regex, type) do
    if Regex.match?(regex, ua) do
      %{device | type: type}
    else
      device
    end
  end

  defp maybe_parse_type(device, _, _, _), do: device

  defp maybe_parse_vendor(%{brand: :unknown} = device, ua) do
    %{device | brand: VendorFragment.parse(ua)}
  end

  defp maybe_parse_vendor(device, _), do: device

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, %{models: models, regex: regex} = entry} | database]) do
    if Regex.match?(regex, ua) do
      ua
      |> parse_model(entry, models)
      |> maybe_no_model(entry)
    else
      parse(ua, database)
    end
  end

  defp parse_hbbtv(ua) do
    case parse(ua, DevicesHbbTV.list()) do
      :unknown -> %Result.Device{type: "tv"}
      device -> device
    end
  end

  defp parse_regular(ua) do
    case parse(ua, DevicesRegular.list()) do
      :unknown -> %Result.Device{}
      device -> device
    end
  end

  defp parse_model(_, _, []), do: :unknown

  defp parse_model(ua, device, [%{regex: regex} = model | models]) do
    if Regex.match?(regex, ua) do
      parse_model_data(ua, device, model)
    else
      parse_model(ua, device, models)
    end
  end

  defp parse_model_data(ua, %{brand: device_brand}, %{
         brand: brand,
         device: device,
         model: model,
         regex: regex
       }) do
    captures = Regex.run(regex, ua)

    model_str =
      model
      |> Util.uncapture(captures)
      |> Util.sanitize_model()
      |> Util.maybe_unknown()

    brand_str = Util.maybe_unknown(brand || device_brand)

    %Result.Device{
      brand: brand_str,
      type: device || :unknown,
      model: model_str
    }
  end
end
