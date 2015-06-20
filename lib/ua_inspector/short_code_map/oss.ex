defmodule UAInspector.ShortCodeMap.OSs do
  @moduledoc """
  Operating System Short Code Map.
  """

  use UAInspector.ShortCodeMap

  @ets_table :ua_inspector_short_code_map_oss

  def load() do
    UAInspector.ShortCodes.OS.list |> Enum.each fn (code) ->
      :ets.insert_new(@ets_table, code)
    end
  end

  def to_long(short) do
    list
    |> Enum.find({ short, short }, fn ({ s, _ }) -> short == s end)
    |> elem(1)
  end

  def to_short(long) do
    list
    |> Enum.find({ long, long }, fn ({ _, l }) -> long == l end)
    |> elem(0)
  end
end
