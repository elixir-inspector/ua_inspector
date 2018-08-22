defmodule UAInspector.Parser.VendorFragment do
  @moduledoc """
  UAInspector vendor fragment information parser.
  """

  alias UAInspector.Database.VendorFragments

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, VendorFragments.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, entry} | database]) do
    if parse_brand(ua, entry.regexes) do
      entry.brand
    else
      parse(ua, database)
    end
  end

  defp parse_brand(_, []), do: false

  defp parse_brand(ua, [regex | regexes]) do
    if Regex.match?(regex, ua) do
      true
    else
      parse_brand(ua, regexes)
    end
  end
end
