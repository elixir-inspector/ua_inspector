defmodule ExAgent.Parser.UA do
  @doc """
  Parses the user agent (browser) from a user agent.
  """
  @spec parse(String.t) :: ExAgent.Response.UA.t
  def parse(user_agent) do
    parse_ua(user_agent, ExAgent.Regexes.get(:ua))
  end

  defp parse_ua(user_agent, [ { _index, regex } | regexes ]) do
    %ExAgent.Regex{ regex: regex_str } = regex

    if Regex.match?(regex_str, user_agent) do
      parse_ua_data(user_agent, regex)
    else
      parse_ua(user_agent, regexes)
    end
  end
  defp parse_ua(_, []), do: %ExAgent.Response.UA{}

  defp parse_ua_data(user_agent, regex) do
    %ExAgent.Regex{
      regex:          regex_str,
      v1_replacement: v1_replacement,
      v2_replacement: v2_replacement,
    } = regex

    captures = Regex.run(regex_str, user_agent)

    %ExAgent.Response.UA{
      family: parse_ua_family(captures),
      major:  parse_ua_major(captures, v1_replacement),
      minor:  parse_ua_minor(captures, v2_replacement),
      patch:  parse_ua_patch(captures),
    }
  end

  defp parse_ua_family(captures), do: Enum.at(captures, 1, :unknown)

  defp parse_ua_major(captures, nil),  do: Enum.at(captures, 2, :unknown)
  defp parse_ua_major(_, replacement), do: replacement

  defp parse_ua_minor(captures, nil),  do: Enum.at(captures, 3, :unknown)
  defp parse_ua_minor(_, replacement), do: replacement

  defp parse_ua_patch(captures), do: Enum.at(captures, 4, :unknown)
end
