defmodule UAInspector.Parser.Client do
  @moduledoc """
  UAInspector client information parser.
  """

  use UAInspector.Parser

  alias UAInspector.Result

  def parse(_,  []),                             do: :unknown
  def parse(ua, [{ _index, entry } | database ]) do
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
      |> uncapture(captures, 0)
      |> String.replace(~r/\$(\d)/, "")
      |> String.strip()
      |> String.replace(~r/\.(\d)0+$/, ".\\1")
      |> maybe_unknown

    %Result.Client{
      name:    entry.name,
      type:    entry.type,
      version: version_str
    }
  end


  defp uncapture(version, [],                     _),    do: version
  defp uncapture(version, [ capture | captures ], index) do
    version
    |> String.replace("\$#{ index }", capture)
    |> uncapture(captures, index + 1)
  end
end
