defmodule UAInspector.Parser.Bot do
  @moduledoc false

  alias UAInspector.Database.Bots
  alias UAInspector.Result

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, Bots.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [
         {_index, %{category: category, name: name, producer: producer, regex: regex, url: url}}
         | database
       ]) do
    if Regex.match?(regex, ua) do
      %Result.Bot{
        user_agent: ua,
        name: name,
        category: category,
        producer: producer_info(producer),
        url: url
      }
    else
      parse(ua, database)
    end
  end

  defp producer_info(nil), do: %Result.BotProducer{}

  defp producer_info(%{name: name, url: url}) do
    %Result.BotProducer{name: name, url: url}
  end
end
