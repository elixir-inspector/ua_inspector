defmodule ExAgent.Parser.Device do
  @doc """
  Parses device information from a user agent.
  """
  @spec parse(String.t) :: Map.t
  def parse(ua) do
    parse_device(ua, ExAgent.Database.Devices.list)
  end

  defp parse_device(ua, [ { _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_model(ua, entry, entry.models)
    else
      parse_device(ua, database)
    end
  end

  defp parse_model(ua, device, [ model | models ]) do
    if Regex.match?(model.regex, ua) do
      %{
        brand:  device.brand,
        device: model.device,
        model:  model.model
      }
    else
      parse_model(ua, device, models)
    end
  end
end
