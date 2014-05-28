defmodule ExAgent.Parser.OS do
  @doc """
  Parses the operating system from a user agent.
  """
  @spec parse(String.t) :: ExAgent.Response.OS.t
  def parse(user_agent) do
    parse_os(user_agent, ExAgent.Regexes.get(:os))
  end

  defp parse_os(user_agent, [ regex | regexes ]) do
    %ExAgent.Regex{ regex: regex_str } = regex

    if Regex.match?(regex_str, user_agent) do
      parse_os_data(user_agent, regex)
    else
      parse_os(user_agent, regexes)
    end
  end
  defp parse_os(_, []), do: %ExAgent.Response.OS{}

  defp parse_os_data(user_agent, regex) do
    %ExAgent.Regex{
      regex:             regex_str,
      os_replacement:    os_replacement,
      os_v1_replacement: os_v1_replacement,
      os_v2_replacement: os_v2_replacement
    } = regex

    captures = Regex.run(regex_str, user_agent)

    %ExAgent.Response.OS{
      family:      parse_os_family(captures, os_replacement),
      major:       parse_os_major(captures, os_v1_replacement),
      minor:       parse_os_minor(captures, os_v2_replacement),
      patch:       parse_os_patch(captures),
      patch_minor: parse_os_patch_minor(captures)
    }
  end

  defp parse_os_family(captures, nil),  do: Enum.at(captures, 1, :unknown)
  defp parse_os_family(_, replacement), do: replacement

  defp parse_os_major(captures, nil),  do: Enum.at(captures, 2, :unknown)
  defp parse_os_major(_, replacement), do: replacement

  defp parse_os_minor(captures, nil),  do: Enum.at(captures, 3, :unknown)
  defp parse_os_minor(_, replacement), do: replacement

  defp parse_os_patch(captures), do: Enum.at(captures, 4, :unknown)

  defp parse_os_patch_minor(captures), do: Enum.at(captures, 5, :unknown)
end
