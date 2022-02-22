defmodule UAInspector.Parser.BrowserEngine do
  @moduledoc false

  alias UAInspector.Database.BrowserEngines

  @behaviour UAInspector.Parser

  @impl UAInspector.Parser
  def parse(ua), do: parse(ua, BrowserEngines.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{regex, engine} | database]) do
    if Regex.match?(regex, ua) do
      engine
    else
      parse(ua, database)
    end
  end
end
