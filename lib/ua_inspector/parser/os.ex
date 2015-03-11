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


  defp maybe_unknown(""),  do: :unknown
  defp maybe_unknown(str), do: str


  defp parse_data(ua, entry) do
    captures    = Regex.run(entry.regex, ua)
    version_str =
         (entry.version || "")
      |> Util.uncapture(captures)
      |> String.replace(~r/\$(\d)/, "")
      |> String.strip()
      |> String.replace(~r/\.(\d)0+$/, ".\\1")
      |> maybe_unknown()

    %Result.OS{
      name:    entry.name,
      version: version_str
    }
  end
end