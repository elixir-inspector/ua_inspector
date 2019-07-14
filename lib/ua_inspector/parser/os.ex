defmodule UAInspector.Parser.OS do
  @moduledoc false

  alias UAInspector.Database.OSs
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  @platforms [
    {"ARM", Util.build_regex("arm")},
    {"x64", Util.build_regex("WOW64|x64|win64|amd64|x86_64")},
    {"x86", Util.build_regex("i[0-9]86|i86pc")}
  ]

  def parse(ua), do: parse(ua, OSs.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, {_, regex, _} = entry} | database]) do
    if Regex.match?(regex, ua) do
      %Result.OS{
        name: resolve_name(ua, entry),
        platform: resolve_platform(ua),
        version: resolve_version(ua, entry)
      }
    else
      parse(ua, database)
    end
  end

  defp resolve_name(ua, {name, regex, _}) do
    captures = Regex.run(regex, ua)

    name
    |> Util.uncapture(captures)
    |> Util.sanitize_name()
    |> String.downcase()
    |> Util.OS.proper_case()
    |> Util.maybe_unknown()
  end

  defp resolve_version(ua, {_, regex, version}) do
    captures = Regex.run(regex, ua)

    version
    |> Util.uncapture(captures)
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end

  defp resolve_platform(ua), do: resolve_platform(ua, @platforms)

  defp resolve_platform(_, []), do: :unknown

  defp resolve_platform(ua, [{id, regex} | platforms]) do
    if Regex.match?(regex, ua) do
      id
    else
      resolve_platform(ua, platforms)
    end
  end
end
