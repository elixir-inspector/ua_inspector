defmodule UAInspector.ShortCodeMap.OSFamilies do
  @moduledoc """
  Operating System Short Code Map.
  """

  use UAInspector.ShortCodeMap,
    ets_prefix: :ua_inspector_scm_os_families,
    file_local: "short_codes.os_families.yml",
    file_remote: "Parser/OperatingSystem.php",
    var_name: "osFamilies",
    var_type: :hash_with_list

  def to_ets([{short, long}]), do: {short, long}
end
