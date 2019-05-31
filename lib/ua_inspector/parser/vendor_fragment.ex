defmodule UAInspector.Parser.VendorFragment do
  @moduledoc false

  alias UAInspector.Database.VendorFragments

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, VendorFragments.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, %{brand: brand, regexes: regexes}} | database]) do
    if parse_brand(ua, regexes) do
      brand
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
