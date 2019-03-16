defmodule UAInspector.ShortCodeMap.DesktopFamilies do
  @moduledoc false

  use UAInspector.ShortCodeMap,
    ets_prefix: :ua_inspector_scm_desktop_families,
    file_local: "short_codes.desktop_families.yml",
    file_remote: "DeviceDetector.php",
    var_name: "desktopOsArray",
    var_type: :list

  def to_ets(item), do: {item}
end
