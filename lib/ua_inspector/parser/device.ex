defmodule UAInspector.Parser.Device do
  @moduledoc false

  alias UAInspector.Database.DevicesHbbTV
  alias UAInspector.Database.DevicesNotebooks
  alias UAInspector.Database.DevicesRegular
  alias UAInspector.Database.DevicesShellTV
  alias UAInspector.Parser.VendorFragment
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser.Behaviour

  @desktop_pos Util.Regex.build_regex("(?:Windows (?:NT|IoT)|X11; Linux x86_64)")
  @desktop_neg Util.Regex.build_regex(
                 "CE-HTML| Mozilla/|Andr[o0]id|Tablet|Mobile|iPhone|Windows Phone|ricoh|OculusBrowser|PicoBrowser|Lenovo|compatible; MSIE|Trident/|Tesla/|XBOX|FBMD/|ARM; ?([^)]+)"
               )

  @frozen_android Regex.compile!(
                    "Android (?:10[.\d]*; K(?: Build/|[;)])|1[1-5]\\)) AppleWebKit",
                    [:caseless]
                  )

  @hbbtv Util.Regex.build_regex("HbbTV/([1-9]{1}(?:\.[0-9]{1}){1,2})")
  @notebook Util.Regex.build_regex("FBMD/")
  @shelltv Util.Regex.build_regex("[a-z]+[ _]Shell[ _]\\w{6}|tclwebkit(\\d+[\.\\d]*)")

  @form_factors_type_map [
    {"automotive", "car browser"},
    {"xr", "wearable"},
    {"watch", "wearable"},
    {"mobile", "smartphone"},
    {"tablet", "tablet"},
    {"desktop", "desktop"},
    {"eink", "tablet"}
  ]

  @impl UAInspector.Parser.Behaviour
  def parse(ua, client_hints) do
    client_hints
    |> parse_hints()
    |> parse_device(client_hints, ua)
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

  defp desktop?(ua), do: Regex.match?(@desktop_pos, ua) && !Regex.match?(@desktop_neg, ua)

  defp parse_device(%{model: :unknown} = hints_result, client_hints, ua) do
    if desktop?(ua) or Regex.match?(@frozen_android, ua) do
      hints_result
    else
      parse_device_details(hints_result, client_hints, ua)
    end
  end

  defp parse_device(
         %{model: model} = hints_result,
         %{platform_version: platform_version} = client_hints,
         ua
       ) do
    ua =
      ua
      |> patch_ua_frozen_android(model, platform_version)
      |> patch_ua_desktop(model)

    parse_device_details(hints_result, client_hints, ua)
  end

  defp parse_device(%{model: model} = hints_result, client_hints, ua) when is_binary(model) do
    ua = patch_ua_desktop(ua, model)

    parse_device_details(hints_result, client_hints, ua)
  end

  defp parse_device(hints_result, client_hints, ua),
    do: parse_device_details(hints_result, client_hints, ua)

  defp parse_device_details(hints_result, client_hints, ua) do
    agent_result =
      cond do
        Regex.match?(@hbbtv, ua) -> parse_hbbtv(ua)
        Regex.match?(@shelltv, ua) -> parse_shelltv(ua)
        Regex.match?(@notebook, ua) -> parse_notebook(ua)
        true -> parse_regular(ua)
      end
      |> maybe_parse_vendor(ua, client_hints)

    merge_results(hints_result, agent_result)
  end

  defp patch_ua_desktop(ua, model) do
    if desktop?(ua) do
      Regex.replace(
        ~r/(X11; Linux x86_64)/,
        ua,
        "X11; Linux x86_64; #{model}"
      )
    else
      ua
    end
  end

  defp patch_ua_frozen_android(ua, model, platform_version) do
    if Regex.match?(@frozen_android, ua) do
      os_version =
        case platform_version do
          :unknown -> "10"
          "" -> "10"
          _ -> platform_version
        end

      Regex.replace(
        ~r/(Android (?:10[.\d]*; K|1[1-5]))/,
        ua,
        "Android #{os_version}; #{model}"
      )
    else
      ua
    end
  end

  defp merge_results(%{} = hints_result, %{} = agent_result) do
    Map.merge(hints_result, agent_result, fn
      _, hints_value, :unknown -> hints_value
      _, _, agent_value -> agent_value
    end)
  end

  defp merge_results(_, agent_result), do: agent_result

  defp do_parse(_, []), do: :unknown

  defp do_parse(ua, [{regex, {_, models, _, _} = device_result} | database]) do
    if Regex.match?(regex, ua) do
      parse_model(ua, device_result, models)
    else
      do_parse(ua, database)
    end
  end

  defp maybe_parse_vendor(%{brand: :unknown} = device, ua, client_hints) do
    %{device | brand: VendorFragment.parse(ua, client_hints)}
  end

  defp maybe_parse_vendor(device, _, _), do: device

  defp parse_hints(%{form_factors: form_factors, model: model})
       when is_binary(model) or 0 < length(form_factors) do
    device_model = Util.maybe_unknown(model)
    device_type = parse_hints_form_factors(@form_factors_type_map, form_factors)

    %Result.Device{type: device_type, model: device_model}
  end

  defp parse_hints(_), do: :unknown

  defp parse_hints_form_factors(_, []), do: :unknown

  defp parse_hints_form_factors([{factor, device_type} | form_factors_type_map], form_factors) do
    if Enum.member?(form_factors, factor) do
      device_type
    else
      parse_hints_form_factors(form_factors_type_map, form_factors)
    end
  end

  defp parse_hints_form_factors([], _), do: :unknown

  defp parse_hbbtv(ua) do
    case do_parse(ua, DevicesHbbTV.list()) do
      :unknown -> %Result.Device{type: "tv"}
      device -> device
    end
  end

  defp parse_shelltv(ua) do
    case do_parse(ua, DevicesShellTV.list()) do
      :unknown -> %Result.Device{type: "tv"}
      device -> device
    end
  end

  defp parse_notebook(ua) do
    case do_parse(ua, DevicesNotebooks.list()) do
      :unknown -> parse_regular(ua)
      device -> device
    end
  end

  defp parse_regular(ua) do
    case do_parse(ua, DevicesRegular.list()) do
      :unknown -> %Result.Device{}
      device -> device
    end
  end

  defp parse_model(_, {brand, _, device, _}, []) do
    %Result.Device{
      brand: Util.maybe_unknown(brand),
      type: Util.maybe_unknown(device)
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
      case Util.Regex.uncapture(model, captures) do
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
      type: Util.maybe_unknown(model_device || device),
      model: result_model
    }
  end
end
