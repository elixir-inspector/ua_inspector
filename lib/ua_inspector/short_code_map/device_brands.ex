defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc """
  Device Brand Short Code Map.
  """

  @ets_table   :ua_inspector_short_code_map_device_brands
  @remote_base "https://raw.githubusercontent.com/piwik/device-detector/master"

  use UAInspector.ShortCodeMap, [
    file_local:  "short_codes.device_brands.yml",
    file_remote: "#{ @remote_base }/Parser/Device/DeviceParserAbstract.php",
    file_var:    "deviceBrands",

    ets_table: @ets_table
  ]

  def store_entry([{ short, long }]) do
    :ets.insert_new(@ets_table, { short, long })
  end
end
