defmodule UAInspector.ShortCodeMap.OSs do
  @moduledoc """
  Operating System Short Code Map.
  """

  use UAInspector.ShortCodeMap,
    ets_prefix: :ua_inspector_scm_oss,
    file_local: "short_codes.oss.yml",
    file_remote: "Parser/OperatingSystem.php",
    var_name: "operatingSystems",
    var_type: :hash

  def to_ets([{short, long}]), do: {short, long}
end
