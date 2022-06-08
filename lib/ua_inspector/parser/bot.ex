defmodule UAInspector.Parser.Bot do
  @moduledoc false

  alias UAInspector.Database.Bots
  alias UAInspector.Result

  @behaviour UAInspector.Parser

  @impl UAInspector.Parser
  def parse(ua, _), do: do_parse(ua, Bots.list())

  defp do_parse(_, []), do: :unknown

  defp do_parse(ua, [{regex, result} | database]) do
    if Regex.match?(regex, ua) do
      result(ua, result)
    else
      do_parse(ua, database)
    end
  end

  defp result(ua, {category, name, url, nil}) do
    %Result.Bot{
      user_agent: ua,
      name: name,
      category: category,
      producer: %Result.BotProducer{},
      url: url
    }
  end

  defp result(ua, {category, name, url, {producer_name, producer_url}}) do
    %Result.Bot{
      user_agent: ua,
      name: name,
      category: category,
      producer: %Result.BotProducer{
        name: producer_name,
        url: producer_url
      },
      url: url
    }
  end
end
