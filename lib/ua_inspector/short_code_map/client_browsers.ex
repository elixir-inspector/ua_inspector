defmodule UAInspector.ShortCodeMap.ClientBrowsers do
  @moduledoc false

  use UAInspector.ShortCodeMap

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.client_browsers.yml",
     Config.database_url(:short_code_map, "Parser/Client/Browser.php")}
  end

  def to_ets([{short, long}]), do: {short, long}
  def var_name, do: "availableBrowsers"
  def var_type, do: :hash
end
