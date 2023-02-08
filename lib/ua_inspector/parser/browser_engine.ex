defmodule UAInspector.Parser.BrowserEngine do
  @moduledoc false

  alias UAInspector.Database.BrowserEngines

  @behaviour UAInspector.Parser.Behaviour

  @impl UAInspector.Parser.Behaviour
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
