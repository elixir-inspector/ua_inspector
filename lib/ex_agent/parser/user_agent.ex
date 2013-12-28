defmodule ExAgent.Parser.UserAgent do
  @doc """
  Parses the user agent (browser) from a user agent.
  """
  @spec parse(String.t) :: tuple
  def parse(ua) do
    ua |> parse_ua(ExAgent.Regexes.get(:user_agent))
  end

  defp parse_ua(ua, [regex | regexes]) do
    case Regex.run(regex[:regex], ua) do
      captures when is_list(captures) ->
        [ family:  captures |> Enum.at(1) |> String.downcase() |> binary_to_atom(),
          version: :unknown ]
      _ -> ua |> parse_ua(regexes)
    end
  end

  defp parse_ua(_, []) do
    [ family: :unknown, version: :unknown ]
  end
end
