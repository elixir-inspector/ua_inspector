defmodule UAInspector.ShortCodeMap.MobileBrowsers do
  @moduledoc """
  Mobile Browser Short Code Map.
  """

  @remote_base "https://raw.githubusercontent.com/piwik/device-detector/master"

  use UAInspector.ShortCodeMap, [
    file_local:  "short_codes.mobile_browsers.yml",
    file_remote: "#{ @remote_base }/Parser/Client/Browser.php",
    var_name:    "mobileOnlyBrowsers",
    var_type:    :list
  ]

  def to_ets(item), do: { item }
end
