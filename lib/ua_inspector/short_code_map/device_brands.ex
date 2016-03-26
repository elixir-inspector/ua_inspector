defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc """
  Device Brand Short Code Map.
  """

  @remote_base "https://raw.githubusercontent.com/piwik/device-detector/master"

  use UAInspector.ShortCodeMap, [
    file_local:  "short_codes.device_brands.yml",
    file_remote: "#{ @remote_base }/Parser/Device/DeviceParserAbstract.php",
    var_name:    "deviceBrands"
  ]

  def to_ets([{ short, long }]), do: { short, long }
end
