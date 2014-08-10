defmodule ExAgent.Parser.Client do
  @doc """
  Parses client information from a user agent.
  """
  @spec parse(String.t) :: Map.t
  def parse(ua) do
    parse_client(ua, ExAgent.Database.Clients.list)
  end

  defp parse_client(ua, [ { _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_client_data(ua, entry)
    else
      parse_client(ua, database)
    end
  end

  defp parse_client_data(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    %{
      name:    entry.name,
      version: Enum.at(captures, 1) || ""
    }
  end
end
