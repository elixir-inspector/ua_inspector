defmodule UAInspector.Parser.OS do
  @moduledoc false

  alias UAInspector.Database.OSs, as: OSsDatabase
  alias UAInspector.Result
  alias UAInspector.ShortCodeMap.OSs, as: OSsShortCodeMap
  alias UAInspector.Util
  alias UAInspector.Util.ClientHintMapping
  alias UAInspector.Util.OS

  @behaviour UAInspector.Parser.Behaviour

  @android_apps [
    "com.hisense.odinbrowser",
    "com.seraphic.openinet.pre",
    "com.appssppa.idesktoppcbrowser",
    "every.browser.inc"
  ]

  @fire_os_version_mapping %{
    "11" => "8",
    "10" => "8",
    "9" => "7",
    "7" => "6",
    "5" => "5",
    "4.4.3" => "4.5.1",
    "4.4.2" => "4",
    "4.2.2" => "3",
    "4.0.3" => "3",
    "4.0.2" => "3",
    "4" => "2",
    "2" => "1"
  }

  @platforms [
    {"ARM", Util.build_regex("arm|aarch64|Apple ?TV|Watch ?OS|Watch1,[12]")},
    {"SuperH", Util.build_regex("sh4")},
    {"SPARC64", Util.build_regex("sparc64")},
    {"MIPS", Util.build_regex("mips")},
    {"x64", Util.build_regex("64-?bit|WOW64|(?:Intel)?x64|WINDOWS_64|win64|amd64|x86_?64")},
    {"x86", Util.build_regex(".+32bit|.+win32|(?:i[0-9]|x)86|i86pc")}
  ]

  @impl UAInspector.Parser.Behaviour
  def parse(ua, client_hints) do
    hints_result = parse_hints(client_hints)
    agent_result = parse_agent(ua, OSsDatabase.list())

    client_hints
    |> merge_results(hints_result, agent_result)
    |> parse_hints_platform(client_hints, agent_result)
    |> maybe_unknown_os()
  end

  defp maybe_unknown_os(%{name: :unknown, platform: :unknown, version: :unknown}), do: :unknown
  defp maybe_unknown_os(result), do: result

  defp merge_results(%{application: application}, :unknown, _)
       when application in @android_apps,
       do: %Result.OS{name: "Android"}

  defp merge_results(%{application: application}, %{name: name}, _)
       when application in @android_apps and name != "Android",
       do: %Result.OS{name: "Android"}

  defp merge_results(_, :unknown, :unknown), do: %Result.OS{}
  defp merge_results(_, :unknown, agent_result), do: agent_result
  defp merge_results(_, hints_result, :unknown), do: hints_result

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp merge_results(_, hints_result, agent_result) do
    agent_family = OS.family_from_result(agent_result)
    hints_family = OS.family_from_result(hints_result)

    name =
      if hints_result.name != agent_result.name and hints_result.name == agent_family do
        agent_result.name
      else
        hints_result.name
      end

    version =
      cond do
        hints_result.name != :unknown and hints_result.version == :unknown and
            agent_family == hints_family ->
          agent_result.version

        hints_result.version != :unknown ->
          hints_result.version

        true ->
          :unknown
      end

    version =
      cond do
        "Fire OS" == name ->
          parse_fire_os_version(version)

        "HarmonyOS" == name ->
          :unknown

        true ->
          version
      end

    name =
      if "GNU/Linux" == name and "Chrome OS" == agent_result.name and
           hints_result.version == agent_result.version do
        agent_result.name
      else
        name
      end

    %{agent_result | name: name, version: version}
  end

  defp parse_agent(_, []), do: :unknown

  defp parse_agent(ua, [{regex, result} | database]) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> parse_agent(ua, database)
      captures -> result(ua, result, captures)
    end
  end

  defp parse_fire_os_version(version) when is_binary(version) do
    major =
      case String.split(version, ".") do
        [major | _] -> major
        _ -> "0"
      end

    with nil <- Map.get(@fire_os_version_mapping, major),
         nil <- Map.get(@fire_os_version_mapping, version) do
      version
    else
      mapped_version -> mapped_version
    end
  end

  defp parse_fire_os_version(version), do: version

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

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp parse_hints_platform(result, %{architecture: architecture, bitness: bitness}, agent_result)
       when is_binary(architecture) do
    architecture = String.downcase(architecture)

    platform =
      cond do
        String.contains?(architecture, "arm") -> "ARM"
        String.contains?(architecture, "mips") -> "MIPS"
        String.contains?(architecture, "sh4") -> "SuperH"
        String.contains?(architecture, "sparc64") -> "SPARC64"
        String.contains?(architecture, "x64") -> "x64"
        String.contains?(architecture, "x86") and "64" == bitness -> "x64"
        String.contains?(architecture, "x86") -> "x86"
        true -> parse_hints_platform(result, nil, agent_result)
      end

    %{result | platform: platform}
  end

  defp parse_hints_platform(result, _, %{platform: platform}), do: %{result | platform: platform}
  defp parse_hints_platform(result, _, _), do: %{result | platform: :unknown}

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
