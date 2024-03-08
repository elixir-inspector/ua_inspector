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
  alias UAInspector.Util.Browser
  alias UAInspector.Util.ClientHintMapping

  @behaviour UAInspector.Parser.Behaviour

  @is_blink Regex.compile!("Chrome/.+ Safari/537.36", [:caseless])
  @is_iridium_version Regex.compile!("^202[0-4]")

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
  end

  defp merge_results(:unknown, agent_result), do: agent_result
  defp merge_results(hints_result, :unknown), do: hints_result

  defp merge_results(%{name: name, version: version} = hints_result, agent_result)
       when is_binary(name) and is_binary(version) do
    result =
      hints_result
      |> merge_results_iridium(hints_result, agent_result)
      |> merge_results_agent_version(hints_result, agent_result)
      |> merge_results_duckduckgo(hints_result, agent_result)
      |> merge_results_vewd(hints_result, agent_result)
      |> merge_results_chromium(agent_result)

    result =
      if agent_result.name == name <> " Mobile" do
        %{result | name: agent_result.name}
      else
        result
      end

    result =
      if agent_result.name != name and Browser.family(agent_result.name) == Browser.family(name) do
        %{result | engine: agent_result.engine, engine_version: agent_result.engine_version}
      else
        result
      end

    merge_results_version(result, agent_result)
  end

  defp merge_results_iridium(result, %{version: version}, %{
         engine: engine,
         engine_version: engine_version
       }) do
    # If the version reported from the client hints is YYYY or YYYY.MM (e.g., 2022 or 2022.04),
    # then it is the Iridium browser (https://iridiumbrowser.de/news/)
    if Regex.match?(@is_iridium_version, version) do
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

  defp merge_results_agent_version(result, %{name: "Atom"}, %{version: version}),
    do: %{result | version: version}

  defp merge_results_agent_version(result, %{name: "Huawei Browser"}, %{version: version}),
    do: %{result | version: version}

  defp merge_results_agent_version(result, _, _), do: result

  defp merge_results_chromium(%{name: "Chromium"} = result, %{name: "Chromium"}), do: result

  defp merge_results_chromium(%{name: "Chromium"} = result, %{name: name, version: version}),
    do: %{result | name: name, version: version}

  defp merge_results_chromium(result, _), do: result

  defp merge_results_duckduckgo(result, %{name: "DuckDuckGo Privacy Browser"}, _) do
    %{result | version: :unknown}
  end

  defp merge_results_duckduckgo(result, _, _), do: result

  defp merge_results_version(%{name: result_name, version: result_version} = result, %{
         name: result_name,
         engine: agent_engine,
         engine_version: agent_engine_version,
         version: agent_version
       }) do
    version =
      if result_version != agent_version do
        merge_results_version_compare(result_version, agent_version)
      else
        result_version
      end

    %{result | engine: agent_engine, engine_version: agent_engine_version, version: version}
  end

  defp merge_results_version(result, _), do: result

  defp merge_results_version_compare(same_version, same_version), do: same_version
  defp merge_results_version_compare(:unknown, agent_version), do: agent_version
  defp merge_results_version_compare(result_version, :unknown), do: result_version

  defp merge_results_version_compare(result_version, agent_version) do
    agent_semver = Util.to_semver_with_pre(agent_version)
    result_semver = Util.to_semver_with_pre(result_version)

    if String.starts_with?(agent_version, result_version) and
         :lt == Version.compare(result_semver, agent_semver) do
      agent_version
    else
      result_version
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
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> parse_agent(ua, database)
      captures -> result(ua, result, captures)
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
    hint_name = ClientHintMapping.browser_mapping(name)

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
      app_name == nil -> result
      app_name == client_name -> result
      true -> %Result.Client{name: app_name, type: "mobile app"}
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
          if Regex.match?(@is_blink, ua) do
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

  defp resolve_engine([{"default", default}, {"versions", engines}], version) do
    version
    |> Util.to_semver()
    |> resolve_engine_detailed(engines, default)
  end

  defp resolve_engine_detailed(_, [], default), do: default

  defp resolve_engine_detailed(version, [{engine_version, engine} | engines], default) do
    if :lt != Version.compare(version, engine_version) do
      engine
    else
      resolve_engine_detailed(version, engines, default)
    end
  end

  defp resolve_name(nil, _), do: :unknown

  defp resolve_name(name, captures) do
    name
    |> Util.uncapture(captures)
    |> String.trim()
    |> Util.maybe_unknown()
  end

  defp resolve_version(nil, _), do: :unknown

  defp resolve_version(version, captures) do
    version
    |> Util.uncapture(captures)
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end

  defp result(ua, {engine, name, type, version}, captures) do
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
