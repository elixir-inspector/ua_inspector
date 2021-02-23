defmodule UAInspector.Parser.OS do
  @moduledoc false

  alias UAInspector.Database.OSs
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  @platforms [
    {"ARM", Util.build_regex("arm|aarch64|Watch ?OS|Watch1,[12]")},
    {"SuperH", Util.build_regex("sh4")},
    {"MIPS", Util.build_regex("mips")},
    {"x64", Util.build_regex("WOW64|x64|win64|amd64|x86_?64")},
    {"x86", Util.build_regex("(?:i[0-9]|x)86|i86pc")}
  ]

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
    |> Util.sanitize_name()
    |> Util.OS.proper_case()
    |> Util.maybe_unknown()
  end

  defp resolve_version(version, captures) do
    version
    |> Util.uncapture(captures)
    |> Util.sanitize_version()
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

  defp result(ua, {name, version}, captures) do
    %Result.OS{
      name: resolve_name(name, captures),
      platform: resolve_platform(ua, @platforms),
      version: resolve_version(version, captures)
    }
  end
end
