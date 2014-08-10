defmodule ExAgent.Parser do
  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: Map.t
  def parse(ua) do
    %{
      string: ua,
      client: ExAgent.Parser.Client.parse(ua),
      device: ExAgent.Parser.Device.parse(ua),
      os:     ExAgent.Parser.Os.parse(ua)
    }
  end
end
