defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc """
  Device Brand Short Code Map.
  """

  use UAInspector.ShortCodeMap

  @remote_base "https://raw.githubusercontent.com/piwik/device-detector/master"

  @file_local  "short_codes.device_brands.yml"
  @file_remote "#{ @remote_base }/Parser/Device/DeviceParserAbstract.php"
  @file_var    "deviceBrands"

  @ets_table :ua_inspector_short_code_map_device_brands

  def store_entry([{ short, long }]) do
    :ets.insert_new(@ets_table, { short, long })
  end
end
