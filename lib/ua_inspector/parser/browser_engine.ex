defmodule UAInspector.Parser.BrowserEngine do
  @moduledoc """
  UAInspector browser engine information parser.
  """

  alias UAInspector.Database.BrowserEngines

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, BrowserEngines.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, entry} | database]) do
    if Regex.match?(entry.regex, ua) do
      entry.name
    else
      parse(ua, database)
    end
  end
end
