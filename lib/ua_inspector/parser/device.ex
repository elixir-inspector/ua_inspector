defmodule UAInspector.Parser.Device do
  @moduledoc false

  alias UAInspector.Database.DevicesHbbTV
  alias UAInspector.Database.DevicesNotebooks
  alias UAInspector.Database.DevicesRegular
  alias UAInspector.Database.DevicesShellTV
  alias UAInspector.Parser.VendorFragment
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  @hbbtv Util.build_regex("HbbTV/([1-9]{1}(?:\.[0-9]{1}){1,2})")
  @notebook Util.build_regex("FBMD/")
  @shelltv Util.build_regex("[a-z]+[ _]Shell[ _]\\w{6}")

  @android_mobile Util.build_regex("Android( [\.0-9]+)?; Mobile;")
  @android_tablet Util.build_regex("Android( [\.0-9]+)?; Tablet;")
  @opera_tablet Util.build_regex("Opera Tablet")

  @impl UAInspector.Parser
  def parse(ua) do
    cond do
      Regex.match?(@hbbtv, ua) -> parse_hbbtv(ua)
      Regex.match?(@shelltv, ua) -> parse_shelltv(ua)
      Regex.match?(@notebook, ua) -> parse_notebook(ua)
      true -> parse_regular(ua)
    end
    |> maybe_parse_type(ua)
    |> maybe_parse_vendor(ua)
  end

  @doc """
  Parses the version out of a (possible) HbbTV user agent.
  """
  @spec parse_hbbtv_version(String.t()) :: nil | String.t()
  def parse_hbbtv_version(ua) do
    case Regex.run(@hbbtv, ua, capture: :all_but_first) do
      nil -> nil
      [version | _] -> version
    end
  end

  @doc """
  Checks if a devices contains a ShellTV part.
  """
  @spec shelltv?(String.t()) :: boolean
  def shelltv?(ua), do: Regex.match?(@shelltv, ua)

  defp maybe_parse_type(%{type: :unknown} = device, ua) do
    cond do
      Regex.match?(@android_mobile, ua) -> %{device | type: "smartphone"}
      Regex.match?(@android_tablet, ua) -> %{device | type: "tablet"}
      Regex.match?(@opera_tablet, ua) -> %{device | type: "tablet"}
      true -> device
    end
  end

  defp maybe_parse_type(device, _), do: device

  defp maybe_parse_vendor(%{brand: :unknown} = device, ua) do
    %{device | brand: VendorFragment.parse(ua)}
  end

  defp maybe_parse_vendor(device, _), do: device

  defp parse(_, []), do: :unknown

  defp parse(ua, [{regex, {_, models, _, _} = device_result} | database]) do
    if Regex.match?(regex, ua) do
      parse_model(ua, device_result, models)
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

  defp parse_shelltv(ua) do
    case parse(ua, DevicesShellTV.list()) do
      :unknown -> %Result.Device{type: "tv"}
      device -> device
    end
  end

  defp parse_notebook(ua) do
    case parse(ua, DevicesNotebooks.list()) do
      :unknown -> parse_regular(ua)
      device -> device
    end
  end

  defp parse_regular(ua) do
    case parse(ua, DevicesRegular.list()) do
      :unknown -> %Result.Device{}
      device -> device
    end
  end

  defp parse_model(_, {brand, _, device, _}, []) do
    %Result.Device{
      brand: Util.maybe_unknown(brand),
      type: device
    }
  end

  defp parse_model(ua, device_result, [{regex, {_, _, _} = model_result} | models]) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> parse_model(ua, device_result, models)
      captures -> parse_model_data(device_result, model_result, captures)
    end
  end

  defp parse_model_data({device_brand, _, device, _}, {brand, model_device, model}, captures) do
    result_model =
      case Util.uncapture(model, captures) do
        "" ->
          :unknown

        "Build" ->
          :unknown

        model_capture ->
          model_capture
          |> String.replace(~r/\$(\d)/, "")
          |> String.replace("_", " ")
          |> String.replace(~r/ TD$/, "")
          |> String.trim()
          |> Util.maybe_unknown()
      end

    %Result.Device{
      brand: Util.maybe_unknown(brand || device_brand),
      type: model_device || device,
      model: result_model
    }
  end
end
