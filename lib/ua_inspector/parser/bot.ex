defmodule UAInspector.Parser.Bot do
  @moduledoc """
  UAInspector bot information parser.
  """

  use UAInspector.Parser

  alias UAInspector.Database.Bots
  alias UAInspector.Result

  def parse(ua), do: parse(ua, Bots.list)


  defp assemble_result(result, ua) do
    %Result.Bot{
      user_agent: ua,
      name:       result.name,
      category:   result.category || :unknown,
      producer:   assemble_result_producer(result.producer),
      url:        result.url || :unknown,
    }
  end

  defp assemble_result_producer(nil),   do: %Result.BotProducer{}
  defp assemble_result_producer(result) do
    %Result.BotProducer{ name: result.name, url: result.url }
  end

  defp parse(_,  []),                             do: :unknown
  defp parse(ua, [{ _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      entry |> assemble_result(ua)
    else
      parse(ua, database)
    end
  end
end
