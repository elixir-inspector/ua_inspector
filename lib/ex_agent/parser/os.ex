defmodule ExAgent.Parser.Os do
  @doc """
  Parses operating system information from a user agent.
  """
  @spec parse(String.t) :: Map.t
  def parse(ua) do
    parse_os(ua, ExAgent.Database.Oss.list)
  end

  defp parse_os(ua, [ { _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_os_data(ua, entry)
    else
      parse_os(ua, database)
    end
  end

  defp parse_os_data(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    %{
      name:    entry.name,
      version: Enum.at(captures, 1) || ""
    }
  end
end
