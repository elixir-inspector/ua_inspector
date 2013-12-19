defmodule ExAgent.Parser.Device do
  @doc """
  Parses the device from a user agent.
  """
  @spec parse(String.t) :: tuple
  def parse(_) do
    [ family: :unknown ]
  end
end
