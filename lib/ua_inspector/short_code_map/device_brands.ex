defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc false

  use UAInspector.ShortCodeMap,
    ets_prefix: :ua_inspector_scm_device_brands,
    file_local: "short_codes.device_brands.yml",
    file_remote: "Parser/Device/DeviceParserAbstract.php",
    var_name: "deviceBrands",
    var_type: :hash

  def to_ets([{short, long}]), do: {short, long}
end
