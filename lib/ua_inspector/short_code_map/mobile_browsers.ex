defmodule UAInspector.ShortCodeMap.MobileBrowsers do
  @moduledoc false

  use UAInspector.ShortCodeMap

  def file_local, do: "short_codes.mobile_browsers.yml"
  def file_remote, do: Config.database_url(:short_code_map, "Parser/Client/Browser.php")
  def to_ets(item), do: {item}
  def var_name, do: "mobileOnlyBrowsers"
  def var_type, do: :list
end
