defmodule UAInspector.Parser.BrowserEngine do
  @moduledoc false

  alias UAInspector.Database.BrowserEngines

  @behaviour UAInspector.Parser

  @impl UAInspector.Parser
  def parse(ua, _), do: do_parse(ua, BrowserEngines.list())

  defp do_parse(_, []), do: :unknown

  defp do_parse(ua, [{regex, engine} | database]) do
    if Regex.match?(regex, ua) do
      engine
    else
      do_parse(ua, database)
    end
  end
end
