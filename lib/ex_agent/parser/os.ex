defmodule ExAgent.Parser.OS do
  @regexes [
    { :android, %r/Android/i },
    { :ipad,    %r/iPad/i },
    { :iphone,  %r/iPhone/i },
    { :ipod,    %r/iPod/i },
    { :linux,   %r/Linux/i },
    { :osx,     %r/OS X/i },
    { :windows, %r/Windows/i }
  ]

  @doc """
  Parses the operating system from a user agent.
  """
  @spec parse(String.t) :: tuple
  def parse(ua) do
    [ family:  ua |> parse_family(@regexes),
      version: :unknown ]
  end

  defp parse_family(ua, [{ family, re } | families]) do
    case Regex.run(re, ua) do
      nil -> ua |> parse_family(families)
      _   -> family
    end
  end
  defp parse_family(_, []) do
    :unknown
  end
end
