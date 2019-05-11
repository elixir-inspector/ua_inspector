defmodule UAInspector.ShortCodeMap.MobileBrowsers do
  @moduledoc false

  use UAInspector.ShortCodeMap

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.mobile_browsers.yml",
     Config.database_url(:short_code_map, "Parser/Client/Browser.php")}
  end

  def to_ets(item), do: {item}
  def var_name, do: "mobileOnlyBrowsers"
  def var_type, do: :list
end
