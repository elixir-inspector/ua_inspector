defmodule UAInspector.ShortCodeMap.MobileBrowsers do
  @moduledoc """
  Mobile Browser Short Code Map.
  """

  use UAInspector.ShortCodeMap,
    file_local: "short_codes.mobile_browsers.yml",
    file_remote: "Parser/Client/Browser.php",
    var_name: "mobileOnlyBrowsers",
    var_type: :list

  def to_ets(item), do: {item}
end
