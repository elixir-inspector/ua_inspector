defmodule ExAgent.Parser do
  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: ExAgent.Response
  def parse(ua) do
    %ExAgent.Response{
      string: ua,
      device: ua |> ExAgent.Parser.Device.parse(),
      os:     ua |> ExAgent.Parser.OS.parse(),
      ua:     ua |> ExAgent.Parser.UA.parse()
    }
  end
end
