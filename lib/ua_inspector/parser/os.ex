defmodule UAInspector.Parser.OS do
  @moduledoc false

  alias UAInspector.Database.OSs, as: OSsDatabase
  alias UAInspector.Result
  alias UAInspector.ShortCodeMap.OSs, as: OSsShortCodeMap
  alias UAInspector.ShortCodeMap.VersionMappingFireOS
  alias UAInspector.ShortCodeMap.VersionMappingLineageOS
  alias UAInspector.Util

  @behaviour UAInspector.Parser.Behaviour

  @android_apps [
    "com.hisense.odinbrowser",
    "com.seraphic.openinet.pre",
    "com.appssppa.idesktoppcbrowser",
    "every.browser.inc"
  ]

  @impl UAInspector.Parser.Behaviour
  def parse(ua, client_hints) do
    ua = Util.UserAgent.restore_from_client_hints(ua, client_hints)
    hints_result = parse_hints(client_hints)
    agent_result = parse_agent(ua, OSsDatabase.list())

    client_hints
    |> merge_results(hints_result, agent_result)
    |> parse_hints_platform(client_hints, agent_result)
    |> maybe_unknown_os()
  end

  defp maybe_unknown_os(%{name: :unknown, platform: :unknown, version: :unknown}), do: :unknown
  defp maybe_unknown_os(result), do: result

  defp merge_results(%{application: application}, %{name: name}, _)
       when application in @android_apps and name != "Android",
       do: %Result.OS{name: "Android"}

  defp merge_results(%{application: application}, _, %{name: name})
       when application in @android_apps and name != "Android",
       do: %Result.OS{name: "Android"}

  defp merge_results(%{application: "org.lineageos.jelly"}, %{name: name, version: version}, _)
       when name != "Lineage OS" do
    %Result.OS{
      name: "Lineage OS",
      version: resolve_version_mapping(version, VersionMappingLineageOS.list())
    }
  end

  defp merge_results(%{application: "org.lineageos.jelly"}, _, %{name: name, version: version})
       when name != "Lineage OS" do
    %Result.OS{
      name: "Lineage OS",
      version: resolve_version_mapping(version, VersionMappingLineageOS.list())
    }
  end

  defp merge_results(%{application: "org.mozilla.tv.firefox"}, %{name: name, version: version}, _)
       when name != "Fire OS" do
    %Result.OS{
      name: "Fire OS",
      version: resolve_version_mapping(version, VersionMappingFireOS.list())
    }
  end

  defp merge_results(%{application: "org.mozilla.tv.firefox"}, _, %{name: name, version: version})
       when name != "Fire OS" do
    %Result.OS{
      name: "Fire OS",
      version: resolve_version_mapping(version, VersionMappingFireOS.list())
    }
  end

  defp merge_results(_, :unknown, :unknown), do: %Result.OS{}
  defp merge_results(_, :unknown, agent_result), do: agent_result
  defp merge_results(_, hints_result, :unknown), do: hints_result

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp merge_results(_, hints_result, agent_result) do
    agent_family = Util.OS.family_from_result(agent_result)
    hints_family = Util.OS.family_from_result(hints_result)

    name =
      if hints_result.name != agent_result.name and hints_result.name == agent_family do
        agent_result.name
      else
        hints_result.name
      end

    version =
      cond do
        hints_result.version == :unknown and agent_family == hints_family -> agent_result.version
        hints_result.version != :unknown -> hints_result.version
        true -> :unknown
      end

    version =
      cond do
        "Windows" == name and "0.0.0" == version and "10" == agent_result.version -> :unknown
        "Windows" == name and "0.0.0" == version -> agent_result.version
        true -> version
      end

    version =
      cond do
        name == "Fire OS" and hints_result.version != :unknown ->
          resolve_version_mapping(version, VersionMappingFireOS.list())

        name == "HarmonyOS" ->
          :unknown

        name == "LeafOS" ->
          :unknown

        name == "PICO OS" ->
          agent_result.version

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

    version =
      if "Android" == name and "Chrome OS" == agent_result.name do
        :unknown
      else
        version
      end

    name =
      if "Android" == name and "Chrome OS" == agent_result.name do
        agent_result.name
      else
        name
      end

    name =
      if "GNU/Linux" == name and "Meta Horizon" == agent_result.name do
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

  defp parse_hints(%{platform: platform, platform_version: platform_version})
       when is_binary(platform) do
    platform_name = Util.ClientHintMapping.os_mapping(platform)

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

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defp parse_hints_version("Windows", version) do
    parts = String.split(version, ".")

    major =
      with [major | _] <- parts,
           {value, _} when value > 0 <- Integer.parse(major) do
        value
      else
        _ -> 0
      end

    minor =
      with [_, minor | _] <- parts,
           {value, _} when value > 0 <- Integer.parse(minor) do
        value
      else
        _ -> 0
      end

    cond do
      major == 0 and minor == 1 -> "7"
      major == 0 and minor == 2 -> "8"
      major == 0 and minor == 3 -> "8.1"
      major == 0 -> version
      major < 11 -> "10"
      true -> "11"
    end
  end

  defp parse_hints_version(_, version) do
    version
    |> Util.Version.sanitize()
    |> Util.maybe_unknown()
  end

  defp resolve_name(nil, _), do: :unknown

  defp resolve_name(name, captures) do
    name
    |> Util.Regex.uncapture(captures)
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
  defp resolve_subversion(_, version, [], captures), do: Util.Regex.uncapture(version, captures)

  defp resolve_subversion(ua, version, [{regex, subversion} | subversions], captures) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> resolve_subversion(ua, version, subversions, captures)
      captures -> Util.Regex.uncapture(subversion, captures)
    end
  end

  defp resolve_version(ua, version, subversions, captures) do
    ua
    |> resolve_subversion(version, subversions, captures)
    |> Util.Version.sanitize()
    |> Util.maybe_unknown()
  end

  defp resolve_version_mapping(:unknown, _), do: :unknown

  defp resolve_version_mapping(version, mapping) do
    major =
      case String.split(version, ".") do
        [major | _] -> major
        _ -> "0"
      end

    resolve_version_mapping(version, major, mapping)
  end

  defp resolve_version_mapping(_, _, []), do: :unknown

  defp resolve_version_mapping(version, _, [{version, result} | _]), do: result
  defp resolve_version_mapping(_, major, [{major, result} | _]), do: result

  defp resolve_version_mapping(version, major, [_ | mapping]),
    do: resolve_version_mapping(version, major, mapping)

  defp result(ua, {name, version, versions}, captures) do
    platforms = [
      {"ARM",
       Util.Regex.build_regex(
         "arm[ _;)ev]|.*arm$|.*arm64|aarch64|Apple ?TV|Watch ?OS|Watch1,[12]"
       )},
      {"SuperH", Util.Regex.build_regex("sh4")},
      {"SPARC64", Util.Regex.build_regex("sparc64")},
      {"LoongArch64", Util.Regex.build_regex("loongarch64")},
      {"MIPS", Util.Regex.build_regex("mips")},
      {"x64",
       Util.Regex.build_regex("64-?bit|WOW64|(?:Intel)?x64|WINDOWS_64|win64|.*amd64|.*x86_?64")},
      {"x86", Util.Regex.build_regex(".*32bit|.*win32|(?:i[0-9]|x)86|i86pc")}
    ]

    %Result.OS{
      name: resolve_name(name, captures),
      platform: resolve_platform(ua, platforms),
      version: resolve_version(ua, version, versions, captures)
    }
  end
end
