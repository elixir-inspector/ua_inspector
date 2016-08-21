defmodule UAInspector.ShortCodeMap.ClientBrowsers do
  @moduledoc """
  Client Browser Short Code Map.
  """

  use UAInspector.ShortCodeMap, [
    file_local:  "short_codes.client_browsers.yml",
    file_remote: "Parser/Client/Browser.php",
    var_name:    "availableBrowsers",
    var_type:    :hash
  ]

  def to_ets([{ short, long }]), do: { short, long }
end
