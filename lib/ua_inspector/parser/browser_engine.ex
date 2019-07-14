defmodule UAInspector.Parser.BrowserEngine do
  @moduledoc false

  alias UAInspector.Database.BrowserEngines

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, BrowserEngines.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, {regex, name}} | database]) do
    if Regex.match?(regex, ua) do
      name
    else
      parse(ua, database)
    end
  end
end
