defmodule UAInspector.Parser.Bot do
  @moduledoc false

  alias UAInspector.Database.Bots
  alias UAInspector.Result
  alias UAInspector.Util

  @behaviour UAInspector.Parser.Behaviour

  @impl UAInspector.Parser.Behaviour
  def parse(ua, _), do: do_parse(ua, Bots.list())

  defp do_parse(_, []), do: :unknown

  defp do_parse(ua, [{regex, result} | database]) do
    case Regex.run(regex, ua, capture: :all_but_first) do
      nil ->
        do_parse(ua, database)

      captures ->
        {category, name, url, producer} = result
        name = Util.Regex.uncapture(name, captures)

        result(ua, {category, name, url, producer})
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
