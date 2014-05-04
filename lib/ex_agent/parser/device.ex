defmodule ExAgent.Parser.Device do
  @doc """
  Parses the device from a user agent.
  """
  @spec parse(String.t) :: ExAgent.Response.Device
  def parse(user_agent) do
    parse_device(user_agent, ExAgent.Regexes.get(:device))
  end

  defp parse_device(user_agent, [ regex | regexes ]) do
    %ExAgent.Regex{ regex: regex_str } = regex

    if Regex.match?(regex_str, user_agent) do
      parse_device_data(user_agent, regex)
    else
      parse_device(user_agent, regexes)
    end
  end
  defp parse_device(_, []), do: %ExAgent.Response.Device{}

  defp parse_device_data(user_agent, regex) do
    %ExAgent.Regex{
      regex:              regex_str,
      device_replacement: replacement
    } = regex

    captures = Regex.run(regex_str, user_agent)
    family   = Enum.at(captures, 1)

    if nil != replacement do
      replacement = replacement |> String.replace("$", "\\")
      family      = Regex.replace(regex_str, Enum.at(captures, 0), replacement)
    end

    %ExAgent.Response.Device{ family: family }
  end
end
