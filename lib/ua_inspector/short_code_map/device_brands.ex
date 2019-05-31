defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc false

  use UAInspector.ShortCodeMap

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def source do
    {"short_codes.device_brands.yml",
     Config.database_url(:short_code_map, "Parser/Device/DeviceParserAbstract.php")}
  end

  def to_ets([{short, long}]), do: {short, long}
  def var_name, do: "deviceBrands"
  def var_type, do: :hash

  @doc """
  Returns the long representation for a device brand short code.
  """
  @spec to_long(String.t()) :: String.t()
  def to_long(short) do
    list()
    |> Enum.find({short, short}, fn {s, _} -> short == s end)
    |> elem(1)
  end

  @doc """
  Returns the short code for a device brand.
  """
  @spec to_short(String.t()) :: String.t()
  def to_short(long) do
    list()
    |> Enum.find({long, long}, fn {_, l} -> long == l end)
    |> elem(0)
  end
end
