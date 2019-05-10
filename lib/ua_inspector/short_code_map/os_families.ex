defmodule UAInspector.ShortCodeMap.OSFamilies do
  @moduledoc false

  use UAInspector.ShortCodeMap

  def file_local, do: "short_codes.os_families.yml"
  def file_remote, do: Config.database_url(:short_code_map, "Parser/OperatingSystem.php")
  def to_ets([{family, codes}]), do: {family, codes}
  def var_name, do: "osFamilies"
  def var_type, do: :hash_with_list
end
