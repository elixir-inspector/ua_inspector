defmodule UAInspector.ShortCodeMap.DeviceBrands do
  @moduledoc """
  Device Brand Short Code Map.
  """

  use UAInspector.ShortCodeMap

  @ets_table :ua_inspector_short_code_map_device_brands

  def load() do
    UAInspector.ShortCodes.DeviceBrands.list |> Enum.each fn (code) ->
      :ets.insert_new(@ets_table, code)
    end
  end
end
