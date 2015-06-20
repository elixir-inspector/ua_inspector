defmodule UAInspector.ShortCode do
  @moduledoc """
  Utility module to handle (piwik) short codes.
  """

  alias UAInspector.ShortCodes.DeviceBrands


  # pre-generate device_brand/2 methods
  for { short, long } <- DeviceBrands.list do
    def device_brand(unquote(short), :long),  do: unquote(long)
    def device_brand(unquote(long),  :short), do: unquote(short)
  end


  @doc """
  Converts device brands between their `:short` and `:long` representation.

  Unknown brands are returned unmodified.
  """
  @spec device_brand(brand :: String.t, format :: atom) :: String.t
  def device_brand(brand, _), do: brand
end
