defmodule ExAgent do
  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: tuple
  def parse(ua), do: ExAgent.Parser.parse(ua)
end
