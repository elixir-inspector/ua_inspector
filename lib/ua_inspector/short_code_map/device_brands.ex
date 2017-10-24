defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc """
  Device Brand Short Code Map.
  """

  use UAInspector.ShortCodeMap,
    file_local: "short_codes.device_brands.yml",
    file_remote: "Parser/Device/DeviceParserAbstract.php",
    var_name: "deviceBrands",
    var_type: :hash

  def to_ets([{short, long}]), do: {short, long}
end
