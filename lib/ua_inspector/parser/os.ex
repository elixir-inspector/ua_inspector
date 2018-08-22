defmodule UAInspector.Parser.OS do
  @moduledoc """
  UAInspector operating system information parser.
  """

  alias UAInspector.Database.OSs
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, OSs.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, entry} | database]) do
    if Regex.match?(entry.regex, ua) do
      parse_data(ua, entry)
    else
      parse(ua, database)
    end
  end

  defp parse_data(ua, entry) do
    name = resolve_name(ua, entry)
    platform = resolve_platform(ua)
    version = resolve_version(ua, entry)

    %Result.OS{
      name: name,
      platform: platform,
      version: version
    }
  end

  defp resolve_name(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    entry.name
    |> Util.uncapture(captures)
    |> Util.sanitize_name()
    |> String.downcase()
    |> Util.OS.proper_case()
    |> Util.maybe_unknown()
  end

  defp resolve_version(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    entry.version
    |> Util.uncapture(captures)
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end

  @platforms [
    {"ARM", Util.build_regex("arm")},
    {"x64", Util.build_regex("WOW64|x64|win64|amd64|x86_64")},
    {"x86", Util.build_regex("i[0-9]86|i86pc")}
  ]

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
