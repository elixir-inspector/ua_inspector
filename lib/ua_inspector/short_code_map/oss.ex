defmodule UAInspector.ShortCodeMap.OSs do
  @moduledoc """
  Operating System Short Code Map.
  """

  @ets_table   :ua_inspector_short_code_map_oss
  @remote_base "https://raw.githubusercontent.com/piwik/device-detector/master"

  use UAInspector.ShortCodeMap, [
    file_local:  "short_codes.oss.yml",
    file_remote: "#{ @remote_base }/Parser/OperatingSystem.php",
    file_var:    "operatingSystems",

    ets_table: @ets_table
  ]

  def store_entry([{ short, long }]) do
    :ets.insert_new(@ets_table, { short, long })
  end
end
