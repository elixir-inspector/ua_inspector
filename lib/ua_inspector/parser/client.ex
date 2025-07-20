defmodule UAInspector.Parser.Client do
  @moduledoc false

  alias UAInspector.ClientHints
  alias UAInspector.ClientHints.Apps
  alias UAInspector.ClientHints.Browsers
  alias UAInspector.Database.BrowserEngines
  alias UAInspector.Database.Clients
  alias UAInspector.Parser.BrowserEngine
  alias UAInspector.Result
  alias UAInspector.ShortCodeMap.ClientBrowsers
  alias UAInspector.Util

  @behaviour UAInspector.Parser.Behaviour

  @client_hint_browser_user_agent_version [
    "Aloha Browser",
    "Atom",
    "Huawei Browser",
    "Mi Browser",
    "OJR Browser",
    "Opera",
    "Opera Mobile",
    "Veera"
  ]

  @client_hint_chromium_hint_names ["Chromium", "Chrome Webview"]
  @client_hint_chromium_agent_names ["Chromium", "Chrome Webview", "Android Browser"]

  @impl UAInspector.Parser.Behaviour
  def parse(ua, client_hints) do
    hints_result = parse_hints(client_hints)
    agent_result = parse_agent(ua, Clients.list())

    result = merge_results(hints_result, agent_result)

    result
    |> maybe_application(client_hints)
    |> maybe_browser(client_hints, ua)
    |> maybe_fix_flow_browser()
    |> maybe_fix_every_browser()
    |> maybe_fix_tv_browser_internet()
  end

  defp merge_results(:unknown, agent_result), do: agent_result
  defp merge_results(hints_result, :unknown), do: hints_result

  defp merge_results(_, %{name: name, type: "mobile app", version: version} = agent_result)
       when is_binary(name) and is_binary(version),
       do: agent_result

  defp merge_results(%{name: name, version: version} = hints_result, agent_result)
       when is_binary(name) and is_binary(version) do
    result =
      hints_result
      |> merge_results_iridium(hints_result, agent_result)
      |> merge_results_agent_version(hints_result, agent_result)
      |> merge_results_vewd(hints_result, agent_result)
      |> merge_results_chromium(agent_result)

    result =
      if agent_result.name == name <> " Mobile" do
        %{result | name: agent_result.name}
      else
        result
      end

    result =
      cond do
        agent_result.name != name and
            Util.Browser.family(agent_result.name) == Util.Browser.family(name) ->
          %{result | engine: agent_result.engine, engine_version: agent_result.engine_version}

        agent_result.name == name ->
          %{result | engine: agent_result.engine, engine_version: agent_result.engine_version}

        true ->
          result
      end

    result
    |> merge_results_engine_version(agent_result)
    |> merge_results_version_compare(agent_result)
    |> patch_result_duckduckgo()
    |> patch_result_blink(hints_result)
  end

  defp patch_result_blink(
         %{engine: "Blink", name: name, engine_version: result_version} = result,
         %{version: hints_version}
       )
       when name != "Iridium" do
    if :lt == Util.Version.compare(result_version, hints_version) do
      %{result | engine_version: hints_version}
    else
      result
    end
  end

  defp patch_result_blink(result, _), do: result

  defp patch_result_duckduckgo(%{name: "DuckDuckGo Privacy Browser"} = result),
    do: %{result | version: :unknown}

  defp patch_result_duckduckgo(result), do: result

  defp merge_results_iridium(result, %{version: version}, %{
         engine: engine,
         engine_version: engine_version
       }) do
    # If the version reported from the client hints is YYYY or YYYY.MM (e.g., 2022 or 2022.04),
    # then it is the Iridium browser (https://iridiumbrowser.de/news/)
    if Regex.match?(~r/^202[0-4]/, version) do
      %{result | name: "Iridium", engine: engine, engine_version: engine_version}
    else
      result
    end
  end

  defp merge_results_agent_version(result, %{version: "15" <> _}, %{
         version: "114" <> _,
         engine: agent_engine,
         engine_version: agent_engine_version
       }) do
    %{
      result
      | engine: agent_engine,
        engine_version: agent_engine_version,
        name: "360 Secure Browser"
    }
  end

  defp merge_results_agent_version(%{name: browser_name} = result, _, %{version: agent_version})
       when is_binary(agent_version) do
    # use agent version if client hints report one of these browsers
    if browser_name in @client_hint_browser_user_agent_version do
      %{result | version: agent_version}
    else
      result
    end
  end

  defp merge_results_agent_version(result, _, _), do: result

  defp merge_results_chromium(%{name: hint_name} = result, %{
         name: agent_name,
         version: agent_version
       })
       when hint_name in @client_hint_chromium_hint_names and
              is_binary(agent_name) and
              agent_name not in @client_hint_chromium_agent_names,
       do: %{result | name: agent_name, version: agent_version}

  defp merge_results_chromium(result, _), do: result

  defp merge_results_engine_version(%{name: result_name} = result, %{
         name: result_name,
         engine: agent_engine,
         engine_version: agent_engine_version
       }) do
    %{result | engine: agent_engine, engine_version: agent_engine_version}
  end

  defp merge_results_engine_version(result, _), do: result

  defp merge_results_version_compare(%{version: same_version} = result, %{version: same_version}),
    do: result

  defp merge_results_version_compare(%{version: :unknown} = result, %{version: version}),
    do: %{result | version: version}

  defp merge_results_version_compare(result, %{version: :unknown}), do: result

  defp merge_results_version_compare(%{version: result_version} = result, %{
         version: agent_version
       }) do
    cond do
      String.starts_with?(agent_version, result_version) and
          :lt == Util.Version.compare(result_version, agent_version) ->
        %{result | version: agent_version}

      String.starts_with?(agent_version, result_version) and
        :eq == Util.Version.compare(result_version, agent_version) and
          String.length(agent_version) > String.length(result_version) ->
        %{result | version: agent_version}

      true ->
        result
    end
  end

  defp merge_results_vewd(result, %{name: "Vewd Browser"}, %{
         engine: engine,
         engine_version: engine_version
       }) do
    %{result | engine: engine, engine_version: engine_version}
  end

  defp merge_results_vewd(result, _, _), do: result

  defp parse_agent(_, []), do: :unknown

  defp parse_agent(ua, [{regex, result} | database]) do
    with captures when not is_nil(captures) <- Regex.run(regex, ua, capture: :all_but_first),
         %{} = result <- result(ua, result, captures) do
      result
    else
      _ -> parse_agent(ua, database)
    end
  end

  defp parse_hints(%{full_version: full_version, full_version_list: [_ | _] = versions}) do
    case parse_hints_versions(versions, :unknown) do
      {name, version} ->
        client_version =
          if :unknown == full_version do
            version
          else
            full_version
          end

        %Result.Client{name: name, type: "browser", version: client_version}

      :unknown ->
        :unknown
    end
  end

  defp parse_hints(_), do: :unknown

  defp parse_hints_versions([], fallback), do: fallback

  defp parse_hints_versions([{name, version} | versions], fallback) do
    hint_name = Util.ClientHintMapping.browser_mapping(name)

    case ClientBrowsers.find_fuzzy(hint_name) do
      nil -> parse_hints_versions(versions, fallback)
      {_, "Chromium"} -> parse_hints_versions(versions, {"Chromium", version})
      {_, "Microsoft Edge"} -> parse_hints_versions(versions, {"Microsoft Edge", version})
      {_, brand_name} -> {brand_name, version}
    end
  end

  defp find_engine_version(ua, regex) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> :unknown
      ["", version | _] -> version
      [version | _] -> version
    end
  end

  defp maybe_application(result, %ClientHints{application: app}) when is_binary(app) do
    app_name = Apps.list()[app]

    client_name =
      case result do
        :unknown -> :unknown
        %{name: client_name} -> client_name
      end

    cond do
      app_name == nil ->
        result

      client_name == :unknown ->
        result

      app_name != client_name ->
        %Result.Client{name: app_name, type: "mobile app", version: :unknown}

      true ->
        client_version =
          case result do
            :unknown -> :unknown
            %{version: client_version} -> client_version
          end

        %Result.Client{name: client_name, type: "mobile app", version: client_version}
    end
  end

  defp maybe_application(result, _), do: result

  defp maybe_browser(%{type: "mobile app"} = result, _, _), do: result

  defp maybe_browser(result, %ClientHints{application: browser}, ua) when is_binary(browser) do
    browser = String.downcase(browser)
    browser_name = Browsers.list()[browser]

    client_name =
      case result do
        :unknown -> :unknown
        %{name: client_name} -> client_name
      end

    cond do
      browser_name == nil ->
        result

      browser_name == client_name ->
        result

      true ->
        result =
          if :unknown == result do
            %Result.Client{}
          else
            result
          end

        result =
          if Regex.match?(~r(Chrome/.+ Safari/537.36)i, ua) do
            engine_version = parse_browser_engine_version("Blink", ua, BrowserEngines.list())

            %{result | engine: "Blink", engine_version: engine_version}
          else
            result
          end

        %{result | name: browser_name, type: "browser", version: :unknown}
    end
  end

  defp maybe_browser(result, _, _), do: result

  defp maybe_browser_engine("", ua), do: BrowserEngine.parse(ua, nil)
  defp maybe_browser_engine({"", _}, ua), do: BrowserEngine.parse(ua, nil)
  defp maybe_browser_engine(engine, _), do: engine

  defp maybe_fix_every_browser(%{name: "Every Browser"} = result),
    do: %{result | engine: "Blink", engine_version: :unknown}

  defp maybe_fix_every_browser(result), do: result

  defp maybe_fix_flow_browser(%{engine: "Blink", name: "Flow Browser"} = result),
    do: %{result | engine_version: :unknown}

  defp maybe_fix_flow_browser(result), do: result

  defp maybe_fix_tv_browser_internet(%{engine: "Gecko", name: "TV-Browser Internet"} = result),
    do: %{result | engine: "Blink", engine_version: :unknown}

  defp maybe_fix_tv_browser_internet(result), do: result

  defp maybe_resolve_engine("browser", engine_data, ua, version) do
    engine_data
    |> resolve_engine(version)
    |> maybe_browser_engine(ua)
  end

  defp maybe_resolve_engine(_, _, _, _), do: :unknown

  defp parse_browser_engine_version(_, _, []), do: :unknown

  defp parse_browser_engine_version(engine, ua, [{_, {engine, regex}} | _]),
    do: find_engine_version(ua, regex)

  defp parse_browser_engine_version(engine, ua, [_ | engines]),
    do: parse_browser_engine_version(engine, ua, engines)

  defp resolve_engine(nil, _), do: ""
  defp resolve_engine([{"default", default}], _), do: default
  defp resolve_engine([{"default", default}, _], :unknown), do: default

  defp resolve_engine([{"default", default}, {"versions", engines}], version),
    do: resolve_engine_detailed(version, engines, default)

  defp resolve_engine_detailed(_, [], default), do: default

  defp resolve_engine_detailed(version, [{engine_version, engine} | engines], default) do
    if :lt != Util.Version.compare(version, engine_version) do
      engine
    else
      resolve_engine_detailed(version, engines, default)
    end
  end

  defp resolve_name(nil, _), do: :unknown

  defp resolve_name(name, captures) do
    name
    |> Util.Regex.uncapture(captures)
    |> String.trim()
    |> Util.maybe_unknown()
  end

  defp resolve_version(nil, _), do: :unknown

  defp resolve_version(version, captures) do
    version
    |> Util.Regex.uncapture(captures)
    |> Util.Version.sanitize()
    |> Util.maybe_unknown()
  end

  defp result(ua, {engine, name, type, version}, captures) do
    if type == "browser" and Regex.match?(~r/Cypress|PhantomJS/, ua) do
      nil
    else
      version = resolve_version(version, captures)

      {engine, engine_version} =
        case maybe_resolve_engine(type, engine, ua, version) do
          {engine, version_regex} when is_binary(engine) and 0 < byte_size(engine) ->
            {engine, find_engine_version(ua, version_regex)}

          _ ->
            {:unknown, :unknown}
        end

      %Result.Client{
        engine: engine,
        engine_version: engine_version,
        name: resolve_name(name, captures),
        type: type,
        version: version
      }
    end
  end
end
