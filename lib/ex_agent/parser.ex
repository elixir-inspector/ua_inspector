defmodule ExAgent.Parser do
  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: Map.t
  def parse(ua) do
    %{
      string: ua,
      client: ExAgent.Parser.Client.parse(ua, ExAgent.Database.Clients.list),
      device: ExAgent.Parser.Device.parse(ua, ExAgent.Database.Devices.list),
      os:     ExAgent.Parser.Os.parse(ua, ExAgent.Database.Oss.list)
    }
  end
end
