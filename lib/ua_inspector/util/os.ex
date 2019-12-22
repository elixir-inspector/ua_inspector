defmodule UAInspector.Util.OS do
  @moduledoc false

  alias UAInspector.ShortCodeMap

  @doc """
  Checks whether an operating system is treated as "desktop only".
  """
  @spec desktop_only?(String.t()) :: boolean
  def desktop_only?(name) do
    short_code = ShortCodeMap.OSs.to_short(name)

    case family(short_code) do
      nil -> false
      family -> family in ShortCodeMap.DesktopFamilies.list()
    end
  end

  @doc """
  Returns the OS family for an OS short code.

  Unknown short codes return `nil` as their family.
  """
  @spec family(short_code :: String.t()) :: String.t() | nil
  def family(short_code), do: family(short_code, ShortCodeMap.OSFamilies.list())

  @doc """
  Returns the proper case version of an OS name.

  Unknown names are returned unmodified.

  ## Examples

      iex> proper_case("debian")
      "Debian"

      iex> proper_case("--UnKnOnWn--")
      "--UnKnOnWn--"
  """
  @spec proper_case(os :: String.t()) :: String.t()
  def proper_case(os), do: proper_case(os, String.downcase(os), ShortCodeMap.OSs.list())

  defp family(_, []), do: nil

  defp family(short_code, [{name, short_codes} | families]) do
    if short_code in short_codes do
      name
    else
      family(short_code, families)
    end
  end

  defp proper_case(os, _, []), do: os

  defp proper_case(os, lower_os, [{_, entry} | database]) do
    if lower_os == String.downcase(entry) do
      entry
    else
      proper_case(os, lower_os, database)
    end
  end
end
