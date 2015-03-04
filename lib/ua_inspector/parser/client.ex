defmodule UAInspector.Parser.Client do
  @moduledoc """
  UAInspector client information parser.
  """

  use UAInspector.Parser

  alias UAInspector.Result

  def parse(_, []), do: :unknown

  def parse(ua, [ { _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_data(ua, entry)
    else
      parse(ua, database)
    end
  end

  defp parse_data(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    %Result.Client{
      name:    entry.name,
      type:    entry.type,
      version: Enum.at(captures, 1) || :unknown
    }
  end
end
