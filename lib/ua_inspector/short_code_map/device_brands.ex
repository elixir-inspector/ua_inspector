defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc false

  use UAInspector.ShortCodeMap,
    ets_prefix: :ua_inspector_scm_device_brands

  def file_local, do: "short_codes.device_brands.yml"

  def file_remote,
    do: Config.database_url(:short_code_map, "Parser/Device/DeviceParserAbstract.php")

  def to_ets([{short, long}]), do: {short, long}
  def var_name, do: "deviceBrands"
  def var_type, do: :hash
end
