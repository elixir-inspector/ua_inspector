defmodule UAInspector.Parser do
  @moduledoc false

  alias UAInspector.Parser
  alias UAInspector.Result
  alias UAInspector.Result.Bot
  alias UAInspector.ShortCodeMap
  alias UAInspector.Util

  @has_touch Util.build_regex("Touch")
  @is_android_tv Util.build_regex("Andr0id|Android TV")
  @is_chrome_smartphone Util.build_regex("Chrome/[\.0-9]* (?:Mobile|eliboM)")
  @is_chrome_tablet Util.build_regex("Chrome/[\.0-9]* (?!Mobile)")
  @is_misc_tv Util.build_regex("SmartTV|Tizen.+ TV .+$")
  @is_opera_tv_store Util.build_regex("Opera TV Store| OMI/")
  @is_desktop Util.build_regex("Desktop (x(?:32|64)|WOW64)")

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
  Checks if a user agent is a ShellTV.
  """
  @spec shelltv?(String.t()) :: boolean
  def shelltv?(ua), do: Parser.Device.shelltv?(ua)

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
    |> detect_browser_family()
    |> detect_os_family()
    |> maybe_detect_opera_tv_store()
    |> maybe_detect_android_tv()
    |> maybe_detect_tv()
    |> maybe_fix_desktop()
    |> maybe_fix_ios()
    |> maybe_fix_android()
    |> maybe_fix_android_chrome()
    |> maybe_fix_misc_tv()
    |> maybe_fix_windows()
    |> maybe_detect_desktop()
    |> maybe_detect_feature_phone()
    |> maybe_unknown_device()
  end

  defp detect_browser_family(%{client: %{name: client_name, type: "browser"}} = result) do
    %{result | browser_family: Util.Browser.family(client_name) || :unknown}
  end

  defp detect_browser_family(result), do: result

  defp detect_os_family(%{os: %{name: os_name}} = result) do
    os_family =
      os_name
      |> ShortCodeMap.OSs.to_short()
      |> Util.OS.family()

    %{result | os_family: os_family || :unknown}
  end

  defp detect_os_family(result), do: result

  # assume "Andr0id" to be a tv
  defp maybe_detect_android_tv(%{device: device, user_agent: ua} = result) do
    if Regex.match?(@is_android_tv, ua) do
      %{result | device: %{device | type: "tv"}}
    else
      result
    end
  end

  defp maybe_detect_desktop(
         %{client: client, device: %{type: :unknown} = device, os: %{name: os_name}} = result
       ) do
    with true <- Util.OS.desktop_only?(os_name),
         false <- Util.Client.mobile_only?(client) do
      %{result | device: %{device | type: "desktop"}}
    else
      _ -> result
    end
  end

  defp maybe_detect_desktop(result), do: result

  # assume "Opera TV Store" to be a tv
  defp maybe_detect_opera_tv_store(%{device: device, user_agent: ua} = result) do
    if Regex.match?(@is_opera_tv_store, ua) do
      %{result | device: %{device | type: "tv"}}
    else
      result
    end
  end

  # assume "Java ME" devices to be feature phones
  defp maybe_detect_feature_phone(
         %{device: %{type: :unknown} = device, os: %{name: "Java ME"}} = result
       ) do
    %{result | device: %{device | type: "feature phone"}}
  end

  defp maybe_detect_feature_phone(result), do: result

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
         %{device: %{type: "feature phone"} = device, os_family: "Android"} = result
       ) do
    %{result | device: %{device | type: "smartphone"}}
  end

  defp maybe_fix_android(
         %{device: %{type: :unknown} = device, os: %{name: "Android", version: os_version}} =
           result
       ) do
    version = Util.to_semver(os_version)

    cond do
      smartphone_android?(version) -> %{result | device: %{device | type: "smartphone"}}
      tablet_android?(version) -> %{result | device: %{device | type: "tablet"}}
      true -> result
    end
  end

  defp maybe_fix_android(result), do: result

  defp maybe_fix_desktop(%{device: %{type: "desktop"}} = result), do: result

  defp maybe_fix_desktop(%{device: device, user_agent: ua} = result) do
    if Regex.match?(@is_desktop, ua) do
      %{result | device: %{device | type: "desktop"}}
    else
      result
    end
  end

  defp maybe_fix_ios(%{device: %{brand: :unknown} = device, os: %{name: "tvOS"}} = result) do
    %{result | device: %{device | brand: "Apple"}}
  end

  defp maybe_fix_ios(%{device: %{brand: :unknown} = device, os: %{name: "iOS"}} = result) do
    %{result | device: %{device | brand: "Apple"}}
  end

  defp maybe_fix_ios(%{device: %{brand: :unknown} = device, os: %{name: "Mac"}} = result) do
    %{result | device: %{device | brand: "Apple"}}
  end

  defp maybe_fix_ios(%{device: %{brand: :unknown} = device, os: %{name: "watchOS"}} = result) do
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
         %{
           client: %{type: "browser"},
           device: %{type: :unknown} = device,
           os: %{name: "Android"},
           user_agent: ua
         } = result
       ) do
    device_type =
      cond do
        Regex.match?(@is_chrome_smartphone, ua) -> "smartphone"
        Regex.match?(@is_chrome_tablet, ua) -> "tablet"
        true -> :unknown
      end

    %{result | device: %{device | type: device_type}}
  end

  defp maybe_fix_android_chrome(result), do: result

  # assume "SmartTV" and "Tizen TV" to be a tv
  defp maybe_fix_misc_tv(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    if Regex.match?(@is_misc_tv, ua) do
      %{result | device: %{device | type: "tv"}}
    else
      result
    end
  end

  defp maybe_fix_misc_tv(result), do: result

  # assume windows 8 with touch capability is a tablet
  defp maybe_fix_windows(
         %{device: %{type: :unknown} = device, os: %{name: "Windows RT"}} = result
       ) do
    %{result | device: %{device | type: "tablet"}}
  end

  defp maybe_fix_windows(
         %{
           device: %{type: :unknown} = device,
           os: %{name: "Windows", version: os_version},
           user_agent: ua
         } = result
       )
       when is_binary(os_version) do
    with version <- Util.to_semver(os_version),
         true <- :lt != Version.compare(version, "8.0.0"),
         true <- Regex.match?(@has_touch, ua) do
      %{result | device: %{device | type: "tablet"}}
    else
      _ -> result
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
