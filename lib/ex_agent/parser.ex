defmodule ExAgent.Parser do
  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: tuple
  def parse(ua) do
    [ string: ua,
      device: ua |> ExAgent.Parser.Device.parse(),
      os:     ua |> ExAgent.Parser.OS.parse(),
      ua:     ua |> ExAgent.Parser.UserAgent.parse() ]
  end
end
