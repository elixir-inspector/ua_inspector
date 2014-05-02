defmodule ExAgent.Parser.UserAgent do
  @doc """
  Parses the user agent (browser) from a user agent.
  """
  @spec parse(String.t) :: ExAgent.UserAgent
  def parse(ua) do
    ua |> parse_ua(ExAgent.Regexes.get(:user_agent))
  end

  defp parse_ua(ua, [ %ExAgent.Regex{ regex: regex } | regexes ]) do
    case Regex.run(regex, ua) do
      captures when is_list(captures) ->
        %ExAgent.Response.UserAgent{
          family: captures |> Enum.at(1) |> String.downcase()
        }
      _ -> ua |> parse_ua(regexes)
    end
  end

  defp parse_ua(_, []), do: %ExAgent.Response.UserAgent{}
end
