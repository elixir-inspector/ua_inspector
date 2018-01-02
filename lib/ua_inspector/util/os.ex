defmodule UAInspector.Util.OS do
  @moduledoc """
  Utility methods for operating system lookups.
  """

  alias UAInspector.ShortCodeMap

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
    {"Android", ["AND", "CYN", "RZD", "MLD", "MCD"]},
    {"AmigaOS", ["AMG", "MOR"]},
    {"Apple TV", ["ATV"]},
    {"BlackBerry", ["BLB", "QNX"]},
    {"Brew", ["BMP"]},
    {"BeOS", ["BEO", "HAI"]},
    {"Chrome OS", ["COS"]},
    {"Firefox OS", ["FOS"]},
    {"Gaming Console", ["WII", "PS3"]},
    {"Google TV", ["GTV"]},
    {"IBM", ["OS2"]},
    {"iOS", ["IOS"]},
    {"RISC OS", ["ROS"]},
    {
      "GNU/Linux",
      [
        "LIN",
        "ARL",
        "DEB",
        "KNO",
        "MIN",
        "UBT",
        "KBT",
        "XBT",
        "LBT",
        "FED",
        "RHT",
        "VLN",
        "MDR",
        "GNT",
        "SAB",
        "SLW",
        "SSE",
        "CES",
        "BTR",
        "YNS",
        "SAF"
      ]
    },
    {"Mac", ["MAC"]},
    {"Mobile Gaming Console", ["PSP", "NDS", "XBX"]},
    {"Other Mobile", ["WOS", "POS", "SBA", "TIZ", "SMG"]},
    {"Symbian", ["SYM", "SYS", "SY3", "S60", "S40"]},
    {"Unix", ["SOS", "AIX", "HPX", "BSD", "NBS", "OBS", "DFB", "SYL", "IRI", "T64", "INF"]},
    {"WebTV", ["WTV"]},
    {"Windows", ["WIN"]},
    {"Windows Mobile", ["WPH", "WMO", "WCE", "WRT"]}
  ]

  @doc """
  Checks whether an operating system is treated as "desktop only".
  """
  @spec desktop_only?(os :: map | :unknown) :: boolean
  def desktop_only?(%{name: name}) do
    short_code = name |> ShortCodeMap.OSs.to_short()

    case family(short_code) do
      nil -> false
      family -> Enum.any?(@desktopFamilies, &(&1 == family))
    end
  end

  def desktop_only?(_), do: false

  @doc """
  Returns the OS family for an OS short code.

  Unknown short codes return `nil` as their family.
  """
  @spec family(short_code :: String.t()) :: String.t() | nil
  def family(short_code) do
    lookup = Enum.find(@osFamilies, &in_family?(short_code, &1))

    case lookup do
      {name, _} -> name
      _ -> nil
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
  @spec proper_case(os :: String.t()) :: String.t()
  def proper_case(os) do
    ShortCodeMap.OSs.list()
    |> Enum.find({os, os}, fn {_, o} ->
      String.downcase(os) == String.downcase(o)
    end)
    |> elem(1)
  end

  # Internal methods

  defp in_family?(short_code, {_, short_codes}) do
    Enum.any?(short_codes, &(&1 == short_code))
  end
end
