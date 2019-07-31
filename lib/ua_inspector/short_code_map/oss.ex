defmodule UAInspector.ShortCodeMap.OSs do
  @moduledoc false

  use UAInspector.ShortCodeMap

  alias UAInspector.Util.ShortCodeMap, as: ShortCodeMapUtil

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.oss.yml", Config.database_url(:short_code_map, "Parser/OperatingSystem.php")}
  end

  def to_ets([{short, long}]), do: {short, long}
  def var_name, do: "operatingSystems"
  def var_type, do: :hash

  @doc """
  Returns the long representation for a operating system short code.
  """
  @spec to_long(String.t()) :: String.t()
  def to_long(short), do: ShortCodeMapUtil.to_long(list(), short)

  @doc """
  Returns the short code for a operating system.
  """
  @spec to_short(String.t()) :: String.t()
  def to_short(long), do: ShortCodeMapUtil.to_short(list(), long)
end
