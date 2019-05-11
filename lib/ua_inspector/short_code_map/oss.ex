defmodule UAInspector.ShortCodeMap.OSs do
  @moduledoc false

  use UAInspector.ShortCodeMap

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.oss.yml", Config.database_url(:short_code_map, "Parser/OperatingSystem.php")}
  end

  def to_ets([{short, long}]), do: {short, long}
  def var_name, do: "operatingSystems"
  def var_type, do: :hash
end
