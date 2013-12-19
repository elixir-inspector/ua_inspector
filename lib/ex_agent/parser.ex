defmodule ExAgent.Parser do
  @moduledoc """
  Contains parsing logic for user agent strings.
  """

  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: tuple
  def parse(ua) do
    [ string: ua ]
  end
end
