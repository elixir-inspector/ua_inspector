defmodule UAInspector.Util.ShortCodeMap do
  @moduledoc false

  @doc """
  Extracts the short version for an expanded short code.
  """
  @spec to_short([{String.t(), String.t()}], String.t()) :: String.t()
  def to_short([], long), do: long
  def to_short([{short, long} | _], long), do: short
  def to_short([_ | rest], long), do: to_short(rest, long)
end
