defmodule ExAgent.Parser.OS do
  @doc """
  Parses the operating system from a user agent.
  """
  @spec parse(String.t) :: ExAgent.OS
  def parse(os) do
    os |> parse_os(ExAgent.Regexes.get(:os))
  end

  defp parse_os(os, [ %ExAgent.Regex{ regex: regex } | regexes ]) do
    case Regex.run(regex, os) do
      captures when is_list(captures) ->
        %ExAgent.Response.OS{
          family:  captures |> Enum.at(1) |> String.downcase()
        }
      _ -> os |> parse_os(regexes)
    end
  end

  defp parse_os(_, []), do: %ExAgent.Response.OS{}
end
