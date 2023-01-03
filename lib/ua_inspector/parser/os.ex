defmodule UAInspector.Parser.OS do
  @moduledoc false

  alias UAInspector.Database.OSs, as: OSsDatabase
  alias UAInspector.Result
  alias UAInspector.ShortCodeMap.OSs, as: OSsShortCodeMap
  alias UAInspector.Util
  alias UAInspector.Util.ClientHintMapping
  alias UAInspector.Util.OS

  @behaviour UAInspector.Parser

  @platforms [
    {"ARM", Util.build_regex("arm|aarch64|Apple ?TV|Watch ?OS|Watch1,[12]")},
    {"SuperH", Util.build_regex("sh4")},
    {"MIPS", Util.build_regex("mips")},
    {"x64", Util.build_regex("64-?bit|WOW64|(?:Intel)?x64|WINDOWS_64|win64|amd64|x86_?64")},
    {"x86", Util.build_regex(".+32bit|.+win32|(?:i[0-9]|x)86|i86pc")}
  ]

  @impl UAInspector.Parser
  def parse(ua, client_hints) do
    hints_result = parse_hints(client_hints)
    agent_result = parse_agent(ua, OSsDatabase.list())

    merge_results(hints_result, agent_result)
  end

  defp merge_results(:unknown, agent_result), do: agent_result
  defp merge_results(hints_result, :unknown), do: hints_result

  defp merge_results(hints_result, agent_result) do
    name =
      if hints_result.name != agent_result.name &&
           hints_result.name == OS.family_from_result(agent_result) do
        agent_result.name
      else
        hints_result.name
      end

    %{agent_result | name: name}
  end

  defp parse_agent(_, []), do: :unknown

  defp parse_agent(ua, [{regex, result} | database]) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> parse_agent(ua, database)
      captures -> result(ua, result, captures)
    end
  end

  defp parse_hints(%{platform: platform, platform_version: platform_version})
       when is_binary(platform) do
    platform_name = ClientHintMapping.os_mapping(platform)

    case OSsShortCodeMap.find_fuzzy(platform_name) do
      nil ->
        :unknown

      {_, os_name} ->
        os_version = parse_hints_version(os_name, platform_version)

        %Result.OS{name: os_name, version: os_version}
    end
  end

  defp parse_hints(_), do: :unknown

  defp parse_hints_version(_, :unknown), do: :unknown

  defp parse_hints_version("Windows", version) do
    semversion =
      version
      |> Util.sanitize_version()
      |> Util.to_semver()
      |> Version.parse()

    case semversion do
      {:ok, %Version{major: major}} when major > 0 and major < 11 -> "10"
      {:ok, %Version{major: major}} when major > 10 -> "11"
      _ -> :unknown
    end
  end

  defp parse_hints_version(_, version) do
    version
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end

  defp resolve_name(nil, _), do: :unknown

  defp resolve_name(name, captures) do
    name
    |> Util.uncapture(captures)
    |> String.trim()
    |> Util.OS.proper_case()
    |> Util.maybe_unknown()
  end

  defp resolve_platform(_, []), do: :unknown

  defp resolve_platform(ua, [{id, regex} | platforms]) do
    if Regex.match?(regex, ua) do
      id
    else
      resolve_platform(ua, platforms)
    end
  end

  defp resolve_subversion(_, nil, [], _), do: ""
  defp resolve_subversion(_, version, [], captures), do: Util.uncapture(version, captures)

  defp resolve_subversion(ua, version, [{regex, subversion} | subversions], captures) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> resolve_subversion(ua, version, subversions, captures)
      captures -> Util.uncapture(subversion, captures)
    end
  end

  defp resolve_version(ua, version, subversions, captures) do
    ua
    |> resolve_subversion(version, subversions, captures)
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end

  defp result(ua, {name, version, versions}, captures) do
    %Result.OS{
      name: resolve_name(name, captures),
      platform: resolve_platform(ua, @platforms),
      version: resolve_version(ua, version, versions, captures)
    }
  end
end
