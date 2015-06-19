defmodule UAInspector.Parser.OS do
  @moduledoc """
  UAInspector operating system information parser.
  """

  use UAInspector.Parser

  alias UAInspector.Database.OSs
  alias UAInspector.Result
  alias UAInspector.Util

  def parse(ua), do: parse(ua, OSs.list)


  defp parse(_,  []),                             do: :unknown
  defp parse(ua, [{ _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_data(ua, entry)
    else
      parse(ua, database)
    end
  end


  defp parse_data(ua, entry) do
    name    = resolve_name(ua, entry)
    version = resolve_version(ua, entry)

    %Result.OS{
      name:    name,
      version: version
    }
  end


  defp resolve_name(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    (entry.name || "")
    |> Util.uncapture(captures)
    |> Util.sanitize_name()
    |> String.downcase()
    |> Util.OS.proper_case()
    |> Util.maybe_unknown()
  end

  defp resolve_version(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    (entry.version || "")
    |> Util.uncapture(captures)
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end
end
