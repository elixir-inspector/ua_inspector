defmodule UAInspector.Parser do
  @moduledoc false

  alias UAInspector.Parser
  alias UAInspector.Result
  alias UAInspector.Result.Bot
  alias UAInspector.ShortCodeMap
  alias UAInspector.Util

  @has_touch Util.build_regex("Touch")
  @is_chrome_smartphone Util.build_regex("Chrome/[\.0-9]* Mobile")
  @is_opera_tv_store Util.build_regex("Opera TV Store")

  @doc """
  Parses information from a user agent.

  Returns `:unknown` if no information is not found in the database.

      iex> parse("--- undetectable ---")
      :unknown
  """
  @callback parse(ua :: String.t()) :: atom | binary | map

  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t()) :: boolean
  def bot?(ua), do: :unknown != Parser.Bot.parse(ua)

  @doc """
  Checks if a user agent is a HbbTV and returns its version if so.
  """
  @spec hbbtv?(String.t()) :: false | String.t()
  def hbbtv?(ua) do
    case Parser.Device.parse_hbbtv_version(ua) do
      nil -> false
      version -> version
    end
  end

  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t()) :: Result.t() | Bot.t()
  def parse(ua) do
    case Parser.Bot.parse(ua) do
      :unknown -> parse_client(ua)
      bot -> bot
    end
  end

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t()) :: Result.t()
  def parse_client(ua) do
    %Result{
      user_agent: ua,
      client: Parser.Client.parse(ua),
      device: Parser.Device.parse(ua),
      os: Parser.OS.parse(ua)
    }
    |> maybe_detect_tv()
    |> maybe_fix_ios()
    |> maybe_fix_android()
    |> maybe_fix_android_chrome()
    |> maybe_fix_opera_tv_store()
    |> maybe_fix_windows()
    |> maybe_detect_desktop()
    |> maybe_unknown_device()
  end

  defp maybe_detect_desktop(
         %{client: client, device: %{type: :unknown} = device, os: os} = result
       ) do
    desktop_only = Util.OS.desktop_only?(os)
    mobile_only = Util.Client.mobile_only?(client)

    if desktop_only && !mobile_only do
      %{result | device: %{device | type: "desktop"}}
    else
      result
    end
  end

  defp maybe_detect_desktop(result), do: result

  # assume some browsers to be a tv
  defp maybe_detect_tv(%{client: %{name: "Kylo"}, device: %{type: :unknown} = device} = result) do
    %{result | device: %{device | type: "tv"}}
  end

  defp maybe_detect_tv(
         %{client: %{name: "Espial TV Browser"}, device: %{type: :unknown} = device} = result
       ) do
    %{result | device: %{device | type: "tv"}}
  end

  defp maybe_detect_tv(result), do: result

  # Android <  2.0.0 is always a smartphone
  # Android == 3.*   is always a tablet
  # treat Android feature phones as smartphones
  defp maybe_fix_android(%{os: %{version: :unknown}} = result), do: result

  defp maybe_fix_android(
         %{device: %{type: "feature phone"} = device, os: %{name: os_name}} = result
       ) do
    short_code = ShortCodeMap.OSs.to_short(os_name)
    family = Util.OS.family(short_code)

    case family do
      "Android" -> %{result | device: %{device | type: "smartphone"}}
      _ -> result
    end
  end

  defp maybe_fix_android(
         %{device: %{type: :unknown} = device, os: %{name: "Android", version: os_version}} =
           result
       ) do
    version = Util.to_semver(os_version)

    type =
      cond do
        smartphone_android?(version) -> "smartphone"
        tablet_android?(version) -> "tablet"
        true -> :unknown
      end

    %{result | device: %{device | type: type}}
  end

  defp maybe_fix_android(result), do: result

  defp maybe_fix_ios(%{device: %{brand: :unknown} = device, os: %{name: "Apple TV"}} = result) do
    %{result | device: %{device | brand: "Apple"}}
  end

  defp maybe_fix_ios(%{device: %{brand: :unknown} = device, os: %{name: "iOS"}} = result) do
    %{result | device: %{device | brand: "Apple"}}
  end

  defp maybe_fix_ios(%{device: %{brand: :unknown} = device, os: %{name: "Mac"}} = result) do
    %{result | device: %{device | brand: "Apple"}}
  end

  defp maybe_fix_ios(result), do: result

  defp smartphone_android?(version) do
    :lt == Version.compare(version, "2.0.0")
  end

  defp tablet_android?(version) do
    :lt != Version.compare(version, "3.0.0") && :lt == Version.compare(version, "4.0.0")
  end

  defp maybe_fix_android_chrome(
         %{client: %{name: "Chrome"}, device: %{type: :unknown}, os: %{name: "Android"}} = result
       ) do
    fix_android_chrome(result)
  end

  defp maybe_fix_android_chrome(
         %{client: %{name: "Chrome Mobile"}, device: %{type: :unknown}, os: %{name: "Android"}} =
           result
       ) do
    fix_android_chrome(result)
  end

  defp maybe_fix_android_chrome(result), do: result

  defp fix_android_chrome(%{device: device, user_agent: ua} = result) do
    type =
      if Regex.match?(@is_chrome_smartphone, ua) do
        "smartphone"
      else
        "tablet"
      end

    %{result | device: %{device | type: type}}
  end

  # assume "Opera TV Store" to be a tv
  defp maybe_fix_opera_tv_store(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    if Regex.match?(@is_opera_tv_store, ua) do
      %{result | device: %{device | type: "tv"}}
    else
      result
    end
  end

  defp maybe_fix_opera_tv_store(result), do: result

  # assume windows 8 with touch capability is a tablet
  defp maybe_fix_windows(
         %{device: %{type: :unknown} = device, os: %{name: "Windows RT"}} = result
       ) do
    %{result | device: %{device | type: "tablet"}}
  end

  defp maybe_fix_windows(%{os: %{version: :unknown}} = result) do
    result
  end

  defp maybe_fix_windows(
         %{
           device: %{type: :unknown} = device,
           os: %{name: "Windows", version: os_version},
           user_agent: ua
         } = result
       ) do
    version = Util.to_semver(os_version)
    is_gte_8 = :lt != Version.compare(version, "8.0.0")
    is_touch = Regex.match?(@has_touch, ua)

    if is_gte_8 && is_touch do
      %{result | device: %{device | type: "tablet"}}
    else
      result
    end
  end

  defp maybe_fix_windows(result), do: result

  defp maybe_unknown_device(
         %{device: %{type: :unknown, brand: :unknown, model: :unknown}} = result
       ) do
    %{result | device: :unknown}
  end

  defp maybe_unknown_device(result), do: result
end
