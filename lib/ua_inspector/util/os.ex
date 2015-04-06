defmodule UAInspector.Util.OS do
  @moduledoc """
  Utility methods for operating system lookups.
  """

  alias UAInspector.ShortCode
  alias UAInspector.ShortCodes.OS

  @desktopFamilies [
    "AmigaOS",
    "BeOS",
    "Chrome OS",
    "GNU/Linux",
    "IBM",
    "Mac",
    "Unix",
    "Windows"
  ]

  @osFamilies [
    { "Android",                [ "AND", "CYN", "RZD", "MLD", "MCD" ]},
    { "AmigaOS",                [ "AMG", "MOR" ]},
    { "Apple TV",               [ "ATV" ]},
    { "BlackBerry",             [ "BLB", "QNX" ]},
    { "Brew",                   [ "BMP" ]},
    { "BeOS",                   [ "BEO", "HAI" ]},
    { "Chrome OS",              [ "COS" ]},
    { "Firefox OS",             [ "FOS" ]},
    { "Gaming Console",         [ "WII", "PS3" ]},
    { "Google TV",              [ "GTV" ]},
    { "IBM",                    [ "OS2" ]},
    { "iOS",                    [ "IOS" ]},
    { "RISC OS",                [ "ROS" ]},
    { "GNU/Linux",              [ "LIN", "ARL", "DEB", "KNO", "MIN", "UBT", "KBT",
                                  "XBT", "LBT", "FED", "RHT", "VLN", "MDR", "GNT",
                                  "SAB", "SLW", "SSE", "CES", "BTR", "YNS", "SAF" ]},
    { "Mac",                    [ "MAC" ]},
    { "Mobile Gaming Console",  [ "PSP", "NDS", "XBX" ]},
    { "Other Mobile",           [ "WOS", "POS", "SBA", "TIZ", "SMG" ]},
    { "Symbian",                [ "SYM", "SYS", "SY3", "S60", "S40" ]},
    { "Unix",                   [ "SOS", "AIX", "HPX", "BSD", "NBS", "OBS",
                                  "DFB", "SYL", "IRI", "T64", "INF" ]},
    { "WebTV",                  [ "WTV" ]},
    { "Windows",                [ "WIN" ]},
    { "Windows Mobile",         [ "WPH", "WMO", "WCE", "WRT" ]}
  ]


  # pre-generate proper_case/1 methods
  for { _short, long } <- OS.list do
    dclong = long |> String.downcase

    def proper_case(unquote(dclong)), do: unquote(long)
  end


  @doc """
  Checks whether an operating system is treated as "desktop only".
  """
  @spec desktop_only?(name :: String.t) :: boolean
  def desktop_only?(name) do
    short_code = name |> ShortCode.os_name(:short)

    case family(short_code) do
      nil    -> false
      family -> Enum.any?(@desktopFamilies, &( &1 == family ))
    end
  end

  @doc """
  Returns the OS family for an OS short code.

  Unknown short codes return `nil` as their family.
  """
  @spec family(short_code :: String.t) :: String.t | nil
  def family(short_code) do
    lookup = Enum.find(@osFamilies, &in_family?(short_code, &1))

    case lookup do
      { name, _ } -> name
      _           -> nil
    end
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


  # Internal methods

  defp in_family?(short_code, { _, short_codes }) do
    Enum.any?(short_codes, &( &1 == short_code ))
  end
end
