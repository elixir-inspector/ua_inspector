defmodule ExAgent.Parser.UserAgent do
  @regexes [
    { :chrome,  %r/Chrome/i },
    { :firefox, %r/Firefox/i },
    { :ie,      %r/MSIE/i },
    { :opera,   %r/Opera/i },
    { :safari,  %r/Safari/i }
  ]

  @doc """
  Parses the user agent (browser) from a user agent.
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
