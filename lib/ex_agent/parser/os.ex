defmodule ExAgent.Parser.OS do
  @doc """
  Parses the operating system from a user agent.
  """
  @spec parse(String.t) :: tuple
  def parse(os) do
    os |> parse_os(ExAgent.Regexes.get(:os))
  end

  defp parse_os(os, [regex | regexes]) do
    case Regex.run(regex[:regex], os) do
      captures when is_list(captures) ->
        [ family:  captures |> Enum.at(1) |> String.downcase() |> binary_to_atom(),
          version: :unknown ]
      _ -> os |> parse_os(regexes)
    end
  end

  defp parse_os(_, []) do
    [ family: :unknown, version: :unknown ]
  end
end
