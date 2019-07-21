defmodule UAInspector.ShortCodeMap.DesktopFamilies do
  @moduledoc false

  use UAInspector.ShortCodeMap

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.desktop_families.yml",
     Config.database_url(:short_code_map, "DeviceDetector.php")}
  end

  def to_ets(item), do: item
  def var_name, do: "desktopOsArray"
  def var_type, do: :list
end
