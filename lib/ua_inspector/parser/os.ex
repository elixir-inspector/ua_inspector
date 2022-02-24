defmodule UAInspector.Parser.OS do
  @moduledoc false

  alias UAInspector.Database.OSs
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  @platforms [
    {"ARM", Util.build_regex("arm|aarch64|Apple ?TV|Watch ?OS|Watch1,[12]")},
    {"SuperH", Util.build_regex("sh4")},
    {"MIPS", Util.build_regex("mips")},
    {"x64", Util.build_regex("64-?bit|WOW64|(?:Intel)?x64|win64|amd64|x86_?64")},
    {"x86", Util.build_regex(".+32bit|.+win32|(?:i[0-9]|x)86|i86pc")}
  ]

  @impl UAInspector.Parser
  def parse(ua), do: parse(ua, OSs.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{regex, result} | database]) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil -> parse(ua, database)
      captures -> result(ua, result, captures)
    end
  end

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
