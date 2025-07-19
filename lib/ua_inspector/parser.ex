defmodule UAInspector.Parser do
  @moduledoc false

  alias UAInspector.ClientHints
  alias UAInspector.ClientHints.Apps
  alias UAInspector.Parser
  alias UAInspector.Result
  alias UAInspector.Result.Bot
  alias UAInspector.Util

  @devices_mobile [
    "camera",
    "feature phone",
    "phablet",
    "portable media player",
    "smartphone",
    "tablet"
  ]
  @devices_non_mobile ["console", "smart display", "tv"]

  @apple_os_names [
    "iOS",
    "iPadOS",
    "Mac",
    "tvOS",
    "watchOS"
  ]

  @tv_browser_names [
    "Crow Browser",
    "Espial TV Browser",
    "Kylo",
    "LUJO TV Browser",
    "LogicUI TV Browser",
    "Open TV Browser",
    "Opera Devices",
    "QJY TV Browser",
    "Quick Search TV",
    "Seraphic Sraf",
    "TiviMate",
    "TV Bro",
    "Vewd Browser"
  ]

  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(Result.t() | Bot.t() | String.t(), ClientHints.t() | nil) :: boolean
  def bot?(%Bot{}, _), do: true
  def bot?(%Result{}, _), do: false
  def bot?(ua, client_hints), do: :unknown != Parser.Bot.parse(ua, client_hints)

  @doc """
  Checks if a user agent is a desktop device.
  """
  @spec desktop?(Result.t() | Bot.t() | String.t(), ClientHints.t() | nil) :: boolean
  def desktop?(%Bot{}, _), do: false
  def desktop?(%Result{os: %{name: :unknown}}, _), do: false

  def desktop?(%Result{os: %{name: os_name}, client: %{type: "browser"} = client}, _) do
    if Util.Client.mobile_only?(client) do
      false
    else
      Util.OS.desktop_only?(os_name)
    end
  end

  def desktop?(%Result{os: %{name: os_name}}, _), do: Util.OS.desktop_only?(os_name)
  def desktop?(%Result{}, _), do: false
  def desktop?(ua, client_hints), do: ua |> parse(client_hints) |> desktop?(client_hints)

  @doc """
  Checks if a user agent is a HbbTV and returns its version if so.
  """
  @spec hbbtv?(Result.t() | Bot.t() | String.t(), ClientHints.t() | nil) :: false | String.t()
  def hbbtv?(%Bot{}, _), do: false
  def hbbtv?(%Result{user_agent: ua}, client_hints), do: hbbtv?(ua, client_hints)

  def hbbtv?(ua, _) do
    case Parser.Device.parse_hbbtv_version(ua) do
      nil -> false
      version -> version
    end
  end

  @doc """
  Checks if a user agent is a mobile device.
  """
  @spec mobile?(Result.t() | Bot.t() | String.t(), ClientHints.t() | nil) :: boolean
  def mobile?(%Bot{}, _), do: false
  def mobile?(_, %ClientHints{mobile: true}), do: true
  def mobile?(%Result{device: %{type: type}}, _) when type in @devices_mobile, do: true
  def mobile?(%Result{device: %{type: type}}, _) when type in @devices_non_mobile, do: false

  def mobile?(%Result{os: %{name: os_name}, client: %{type: "browser"} = client}, _) do
    cond do
      Util.Client.mobile_only?(client) -> true
      os_name == :unknown -> false
      true -> !Util.OS.desktop_only?(os_name)
    end
  end

  def mobile?(%Result{client: %{type: "browser"} = client}, _) do
    if Util.Client.mobile_only?(client) do
      true
    else
      false
    end
  end

  def mobile?(%Result{}, _), do: false
  def mobile?(ua, client_hints), do: ua |> parse(client_hints) |> mobile?(client_hints)

  @doc """
  Checks if a user agent is a ShellTV.
  """
  @spec shelltv?(Result.t() | Bot.t() | String.t(), ClientHints.t() | nil) :: boolean
  def shelltv?(%Bot{}, _), do: false
  def shelltv?(%Result{user_agent: ua}, client_hints), do: shelltv?(ua, client_hints)
  def shelltv?(ua, _), do: Parser.Device.shelltv?(ua)

  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t(), ClientHints.t() | nil) :: Result.t() | Bot.t()
  def parse(ua, client_hints) do
    case Parser.Bot.parse(ua, client_hints) do
      :unknown -> parse_client(ua, client_hints)
      bot -> bot
    end
  end

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t(), ClientHints.t() | nil) :: Result.t()
  def parse_client(ua, client_hints) do
    %Result{
      user_agent: ua,
      client: Parser.Client.parse(ua, client_hints),
      device: Parser.Device.parse(ua, client_hints),
      os: Parser.OS.parse(ua, client_hints)
    }
    |> detect_browser_family(client_hints)
    |> detect_os_family()
    |> maybe_detect_opera_tv_store()
    |> maybe_detect_coolita_tv()
    |> maybe_detect_android_tv()
    |> maybe_detect_tv()
    |> maybe_undetect_apple()
    |> maybe_fix_apple()
    |> maybe_detect_android_vr()
    |> maybe_fix_android_chrome()
    |> maybe_detect_tablet()
    |> maybe_fix_device_type()
    |> maybe_fix_android()
    |> maybe_detect_feature_phone()
    |> maybe_fix_windows()
    |> maybe_detect_puffin_browsers()
    |> maybe_fix_misc_tv()
    |> maybe_detect_desktop()
    |> maybe_fix_desktop()
    |> maybe_unknown_device()
  end

  defp detect_browser_family(
         %{client: %{name: "Wolvic", engine: "Blink", type: "browser"}} = result,
         _
       ),
       do: %{result | browser_family: "Chrome"}

  defp detect_browser_family(
         %{client: %{name: "Wolvic", engine: "Gecko", type: "browser"}} = result,
         _
       ),
       do: %{result | browser_family: "Firefox"}

  defp detect_browser_family(%{client: %{name: client_name, type: "browser"}} = result, %{
         application: app
       })
       when is_binary(app) do
    app_name = Apps.list()[app]

    browser_family =
      if app_name != :unknown do
        Util.Browser.family(client_name) || "Chrome"
      else
        Util.Browser.family(client_name) || :unknown
      end

    %{result | browser_family: browser_family}
  end

  defp detect_browser_family(%{client: %{name: client_name, type: "browser"}} = result, _) do
    %{result | browser_family: Util.Browser.family(client_name) || :unknown}
  end

  defp detect_browser_family(result, _), do: result

  defp detect_os_family(%{os: %{} = os_result} = result) do
    %{result | os_family: Util.OS.family_from_result(os_result)}
  end

  defp detect_os_family(result), do: result

  # assume "Andr0id" to be a tv
  defp maybe_detect_android_tv(%{device: %{type: "peripheral"}} = result), do: result
  defp maybe_detect_android_tv(%{device: %{type: "tv"}} = result), do: result

  defp maybe_detect_android_tv(%{device: device, user_agent: ua} = result) do
    re_is_android_tv =
      Util.Regex.build_base_regex(
        "Andr0id|(?:Android(?: UHD)?|Google) TV|\\(lite\\) TV|BRAVIA|Firebolt| TV$"
      )

    if Regex.match?(re_is_android_tv, ua) do
      %{result | device: %{device | type: "tv"}}
    else
      result
    end
  end

  defp maybe_detect_android_vr(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    re_is_android_vr = Util.Regex.build_base_regex("Android( [.0-9]+)?; Mobile VR;| VR")

    if Regex.match?(re_is_android_vr, ua) do
      %{result | device: %{device | type: "wearable"}}
    else
      result
    end
  end

  defp maybe_detect_android_vr(result), do: result

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

  # assume "Coolita OS" to be a tv
  defp maybe_detect_coolita_tv(%{device: device, os: %{name: "Coolita OS"}} = result) do
    %{result | device: %{device | brand: "coocaa", type: "tv"}}
  end

  defp maybe_detect_coolita_tv(result), do: result

  # assume "Opera TV Store" to be a tv
  defp maybe_detect_opera_tv_store(%{device: device, user_agent: ua} = result) do
    re_is_opera_tv_store = Util.Regex.build_base_regex("Opera TV Store| OMI/")

    if Regex.match?(re_is_opera_tv_store, ua) do
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

  defp maybe_detect_feature_phone(%{device: device, os: %{name: "KaiOS"}} = result) do
    %{result | device: %{device | type: "feature phone"}}
  end

  defp maybe_detect_feature_phone(result), do: result

  defp maybe_detect_puffin_browsers(
         %{device: %{type: :unknown} = device, user_agent: ua} = result
       ) do
    re_is_puffin_desktop = Util.Regex.build_base_regex("Puffin/(?:\\d+[.\\d]+)[LMW]D")
    re_is_puffin_smartphone = Util.Regex.build_base_regex("Puffin/(?:\\d+[.\\d]+)[AIFLW]P")
    re_is_puffin_tablet = Util.Regex.build_base_regex("Puffin/(?:\\d+[.\\d]+)[AILW]T")

    cond do
      Regex.match?(re_is_puffin_desktop, ua) ->
        %{result | device: %{device | type: "desktop"}}

      Regex.match?(re_is_puffin_smartphone, ua) ->
        %{result | device: %{device | type: "smartphone"}}

      Regex.match?(re_is_puffin_tablet, ua) ->
        %{result | device: %{device | type: "tablet"}}

      true ->
        result
    end
  end

  defp maybe_detect_puffin_browsers(result), do: result

  defp maybe_detect_tablet(%{device: %{type: "smartphone"} = device, user_agent: ua} = result) do
    re_is_tablet = Util.Regex.build_base_regex("Pad/APad")

    if Regex.match?(re_is_tablet, ua) do
      %{result | device: %{device | type: "tablet"}}
    else
      result
    end
  end

  defp maybe_detect_tablet(result), do: result

  # assume some browsers to be a tv
  defp maybe_detect_tv(
         %{client: %{name: browser_name}, device: %{type: :unknown} = device} = result
       )
       when browser_name in @tv_browser_names,
       do: %{result | device: %{device | type: "tv"}}

  defp maybe_detect_tv(result), do: result

  # Android <  2.0 is always a smartphone
  # Android == 3.* is always a tablet
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
    cond do
      smartphone_android?(os_version) -> %{result | device: %{device | type: "smartphone"}}
      tablet_android?(os_version) -> %{result | device: %{device | type: "tablet"}}
      true -> result
    end
  end

  defp maybe_fix_android(result), do: result

  defp maybe_fix_apple(%{device: %{brand: :unknown} = device, os: %{name: os_name}} = result)
       when is_binary(os_name) and os_name in @apple_os_names do
    %{result | device: %{device | brand: "Apple"}}
  end

  defp maybe_fix_apple(result), do: result

  defp maybe_fix_desktop(%{device: %{type: "desktop"}} = result), do: result

  defp maybe_fix_desktop(%{device: device, user_agent: ua} = result) do
    re_is_desktop = Util.Regex.build_regex("Desktop(?: (x(?:32|64)|WOW64))?;")

    if Regex.match?(re_is_desktop, ua) do
      %{result | device: %{device | type: "desktop"}}
    else
      result
    end
  end

  defp maybe_fix_device_type(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    re_android_mobile = Util.Regex.build_base_regex("Android( [.0-9]+)?; Mobile;|.*\-mobile$")

    re_android_tablet =
      Util.Regex.build_base_regex("Android( [.0-9]+)?; Tablet;|Tablet(?! PC)|.*\-tablet$")

    re_opera_tablet = Util.Regex.build_base_regex("Opera Tablet")

    cond do
      Regex.match?(re_android_mobile, ua) -> %{result | device: %{device | type: "smartphone"}}
      Regex.match?(re_android_tablet, ua) -> %{result | device: %{device | type: "tablet"}}
      Regex.match?(re_opera_tablet, ua) -> %{result | device: %{device | type: "tablet"}}
      true -> result
    end
  end

  defp maybe_fix_device_type(result), do: result

  defp smartphone_android?(version), do: :lt == Util.Version.compare(version, "2.0")

  defp tablet_android?(version),
    do:
      :lt != Util.Version.compare(version, "3.0") &&
        :lt == Util.Version.compare(version, "4.0")

  defp maybe_fix_android_chrome(
         %{
           device: %{type: :unknown} = device,
           os: %{name: "Android"},
           user_agent: ua
         } = result
       ) do
    re_is_chrome = Util.Regex.build_base_regex("Chrome/[.0-9]*")
    re_is_chrome_smartphone = Util.Regex.build_base_regex("(?:Mobile|eliboM)")
    is_chrome = Regex.match?(re_is_chrome, ua)

    device_type =
      cond do
        is_chrome and Regex.match?(re_is_chrome_smartphone, ua) -> "smartphone"
        is_chrome -> "tablet"
        true -> :unknown
      end

    %{result | device: %{device | type: device_type}}
  end

  defp maybe_fix_android_chrome(result), do: result

  defp maybe_fix_misc_tv(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    re_is_generic_tv = Util.Regex.build_base_regex("\\(TV;")
    re_is_misc_tv = Util.Regex.build_base_regex("SmartTV|Tizen.+ TV .+$")

    cond do
      Regex.match?(re_is_misc_tv, ua) -> %{result | device: %{device | type: "tv"}}
      Regex.match?(re_is_generic_tv, ua) -> %{result | device: %{device | type: "tv"}}
      true -> result
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
    re_has_touch = Util.Regex.build_base_regex("Touch")

    with true <- :lt != Util.Version.compare(os_version, "8"),
         true <- Regex.match?(re_has_touch, ua) do
      %{result | device: %{device | type: "tablet"}}
    else
      _ -> result
    end
  end

  defp maybe_fix_windows(result), do: result

  defp maybe_undetect_apple(%{device: %{brand: "Apple"}, os: %{name: os_name}} = result)
       when is_binary(os_name) and os_name not in @apple_os_names do
    %{result | device: %Result.Device{}}
  end

  defp maybe_undetect_apple(result), do: result

  defp maybe_unknown_device(
         %{device: %{type: :unknown, brand: :unknown, model: :unknown}} = result
       ) do
    %{result | device: :unknown}
  end

  defp maybe_unknown_device(result), do: result
end
