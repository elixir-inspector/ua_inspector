defmodule UAInspector.ShortCodeMap.OSs do
  @moduledoc """
  Operating System Short Code Map.
  """

  use UAInspector.ShortCodeMap

  @remote_base "https://raw.githubusercontent.com/piwik/device-detector/master"

  @file_local  "short_codes.oss.yml"
  @file_remote "#{ @remote_base }/Parser/OperatingSystem.php"
  @file_var    "operatingSystems"

  @ets_table :ua_inspector_short_code_map_oss

  def store_entry([{ short, long }]) do
    :ets.insert_new(@ets_table, { short, long })
  end
end
