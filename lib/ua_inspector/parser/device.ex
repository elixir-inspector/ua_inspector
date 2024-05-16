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

  @frozen_android Regex.compile!("Android 10[.\d]*; K(?: Build/|[;)])", [:caseless])

  @hbbtv Util.Regex.build_regex("HbbTV/([1-9]{1}(?:\.[0-9]{1}){1,2})")
  @notebook Util.Regex.build_regex("FBMD/")
  @shelltv Util.Regex.build_regex("[a-z]+[ _]Shell[ _]\\w{6}|tclwebkit(\\d+[\.\\d]*)")

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

  defp parse_device(%{model: :unknown} = hints_result, client_hints, ua) do
    if Util.Fragment.desktop?(ua) do
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
      if Regex.match?(@frozen_android, ua) do
        os_version =
          case platform_version do
            :unknown -> "10"
            "" -> "10"
            _ -> platform_version
          end

        Regex.replace(
          ~r/(Android 10[.\d]*; K)/,
          ua,
          "Android #{os_version}; #{model}"
        )
      else
        ua
      end

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

  defp merge_results(%{} = hints_result, %{brand: :unknown, model: :unknown, type: :unknown}),
    do: hints_result

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

  defp parse_hints(%{model: model}) when is_binary(model),
    do: %Result.Device{model: Util.maybe_unknown(model)}

  defp parse_hints(_), do: :unknown

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
