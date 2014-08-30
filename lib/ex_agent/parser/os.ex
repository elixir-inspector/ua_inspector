defmodule ExAgent.Parser.Os do
  @moduledoc """
  ExAgent operating system information parser.
  """

  @doc """
  Parses operating system information from a user agent.

  Returns `:unknown` if no information is not found in the database.

      iex> parse("--- undetectable ---", [])
      :unknown
  """
  @spec parse(String.t, Enum.t) :: map

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

    %{
      name:    entry.name,
      version: Enum.at(captures, 1) || ""
    }
  end
end
