defmodule ExAgent.Parser.Device do
  @doc """
  Parses the device from a user agent.
  """
  @spec parse(String.t) :: ExAgent.Device
  def parse(device) do
    device |> parse_device(ExAgent.Regexes.get(:device))
  end

  defp parse_device(device, [ %ExAgent.Regex{ regex: regex } | regexes ]) do
    case Regex.run(regex, device) do
      captures when is_list(captures) ->
        %ExAgent.Device{
          family: captures |> Enum.at(1) |> String.downcase()
        }
      _ -> device |> parse_device(regexes)
    end
  end

  defp parse_device(_, []), do: %ExAgent.Device{}
end
