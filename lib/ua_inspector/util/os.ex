defmodule UAInspector.Util.OS do
  @moduledoc """
  Utility methods for operating system lookups.
  """

  alias UAInspector.ShortCodes.OS

  for { _short, long } <- OS.list do
    dclong = long |> String.downcase

    def proper_case(unquote(dclong)), do: unquote(long)
  end

  @doc """
  Returns the proper case version of a downcase os name.

  Unknown names are returned unmodified.

  ## Examples

      iex> proper_case("debian")
      "Debian"

      iex> proper_case("--UnKnOnWn--")
      "--UnKnOnWn--"
  """
  @spec proper_case(os :: String.t) :: String.t
  def proper_case(os), do: os
end
