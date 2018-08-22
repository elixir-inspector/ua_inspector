defmodule UAInspector.Parser.Bot do
  @moduledoc """
  UAInspector bot information parser.
  """

  alias UAInspector.Database.Bots
  alias UAInspector.Result

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, Bots.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, entry} | database]) do
    if Regex.match?(entry.regex, ua) do
      %Result.Bot{
        user_agent: ua,
        name: entry.name,
        category: entry.category,
        producer: producer_info(entry.producer),
        url: entry.url
      }
    else
      parse(ua, database)
    end
  end

  defp producer_info(nil), do: %Result.BotProducer{}

  defp producer_info(result) do
    %Result.BotProducer{name: result.name, url: result.url}
  end
end
