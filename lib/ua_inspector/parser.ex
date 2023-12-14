defmodule UAInspector.Parser do
  @moduledoc false

  alias UAInspector.ClientHints
  alias UAInspector.ClientHints.Apps
  alias UAInspector.Parser
  alias UAInspector.Result
  alias UAInspector.Result.Bot
  alias UAInspector.Util
  alias UAInspector.Util.Fragment

  @devices_mobile [
    "camera",
    "feature phone",
    "phablet",
    "portable media player",
    "smartphone",
    "tablet"
  ]
  @devices_non_mobile ["console", "smart display", "tv"]

  @has_touch Util.build_base_regex("Touch")
  @is_android_tv Util.build_base_regex(
                   "Andr0id|(?:Android(?: UHD)?|Google) TV|\\(lite\\) TV|BRAVIA"
                 )
  @is_chrome Util.build_base_regex("Chrome/[\.0-9]*")
  @is_chrome_smartphone Util.build_base_regex("(?:Mobile|eliboM) Safari/")
  @is_chrome_tablet Util.build_base_regex("(?!Mobile )Safari/")
  @is_generic_tv Util.build_base_regex("\\(TV;")
  @is_misc_tv Util.build_base_regex("SmartTV|Tizen.+ TV .+$")
  @is_opera_tv_store Util.build_base_regex("Opera TV Store| OMI/")
  @is_tablet Util.build_base_regex("Pad/APad")
  @is_wearable Util.build_base_regex(" VR ")

  @android_mobile Util.build_base_regex("Android( [\.0-9]+)?; Mobile;")
  @android_tablet Util.build_base_regex("Android( [\.0-9]+)?; Tablet;")
  @opera_tablet Util.build_base_regex("Opera Tablet")

  @tv_browser_names [
    "Espial TV Browser",
    "Kylo",
    "LUJO TV Browser",
    "LogicUI TV Browser",
    "Open TV Browser"
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
    |> maybe_detect_android_tv()
    |> maybe_detect_tv()
    |> maybe_undetect_android_apple()
    |> maybe_fix_ios()
    |> maybe_detect_wearable()
    |> maybe_fix_android_chrome()
    |> maybe_detect_tablet()
    |> maybe_fix_device_type()
    |> maybe_fix_android()
    |> maybe_detect_feature_phone()
    |> maybe_fix_windows()
    |> maybe_fix_misc_tv()
    |> maybe_detect_desktop()
    |> maybe_fix_desktop()
    |> maybe_unknown_device()
  end

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

  defp maybe_detect_tablet(%{device: %{type: "smartphone"} = device, user_agent: ua} = result) do
    if Regex.match?(@is_tablet, ua) do
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

  defp maybe_detect_wearable(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    if Regex.match?(@is_wearable, ua) do
      %{result | device: %{device | type: "wearable"}}
    else
      result
    end
  end

  defp maybe_detect_wearable(result), do: result

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
    if Fragment.desktop?(ua) do
      %{result | device: %{device | type: "desktop"}}
    else
      result
    end
  end

  defp maybe_fix_device_type(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    cond do
      Regex.match?(@android_mobile, ua) -> %{result | device: %{device | type: "smartphone"}}
      Regex.match?(@android_tablet, ua) -> %{result | device: %{device | type: "tablet"}}
      Regex.match?(@opera_tablet, ua) -> %{result | device: %{device | type: "tablet"}}
      true -> result
    end
  end

  defp maybe_fix_device_type(result), do: result

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
           device: %{type: :unknown} = device,
           os: %{name: "Android"},
           user_agent: ua
         } = result
       ) do
    is_chrome = Regex.match?(@is_chrome, ua)

    device_type =
      cond do
        is_chrome and Regex.match?(@is_chrome_smartphone, ua) -> "smartphone"
        is_chrome and Regex.match?(@is_chrome_tablet, ua) -> "tablet"
        true -> :unknown
      end

    %{result | device: %{device | type: device_type}}
  end

  defp maybe_fix_android_chrome(result), do: result

  defp maybe_fix_misc_tv(%{device: %{type: :unknown} = device, user_agent: ua} = result) do
    cond do
      Regex.match?(@is_misc_tv, ua) -> %{result | device: %{device | type: "tv"}}
      Regex.match?(@is_generic_tv, ua) -> %{result | device: %{device | type: "tv"}}
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
    with version <- Util.to_semver(os_version),
         true <- :lt != Version.compare(version, "8.0.0"),
         true <- Regex.match?(@has_touch, ua) do
      %{result | device: %{device | type: "tablet"}}
    else
      _ -> result
    end
  end

  defp maybe_fix_windows(result), do: result

  defp maybe_undetect_android_apple(%{device: %{brand: "Apple"}, os: %{name: "Android"}} = result) do
    %{result | device: %Result.Device{}}
  end

  defp maybe_undetect_android_apple(result), do: result

  defp maybe_unknown_device(
         %{device: %{type: :unknown, brand: :unknown, model: :unknown}} = result
       ) do
    %{result | device: :unknown}
  end

  defp maybe_unknown_device(result), do: result
end
