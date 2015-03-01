defmodule UAInspector.Parser.Device do
  @moduledoc """
  UAInspector device information parser.
  """

  use UAInspector.Parser

  def parse(_, []), do: :unknown

  def parse(ua, [ { _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_model(ua, entry, entry.models)
    else
      parse(ua, database)
    end
  end

  defp parse_model(_, _, []), do: :unknown

  defp parse_model(ua, device, [ model | models ]) do
    if Regex.match?(model.regex, ua) do
      %{
        brand: device.brand,
        type:  model.device,
        model: model.model
      }
    else
      parse_model(ua, device, models)
    end
  end
end
