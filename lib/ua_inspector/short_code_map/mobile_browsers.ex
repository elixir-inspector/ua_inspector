defmodule UAInspector.ShortCodeMap.MobileBrowsers do
  @moduledoc false

  use UAInspector.ShortCodeMap,
    ets_prefix: :ua_inspector_scm_mobile_browsers,
    file_local: "short_codes.mobile_browsers.yml",
    file_remote: "Parser/Client/Browser.php",
    var_name: "mobileOnlyBrowsers",
    var_type: :list

  def to_ets(item), do: {item}
end
