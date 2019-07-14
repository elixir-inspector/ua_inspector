defmodule UAInspector.Parser.VendorFragment do
  @moduledoc false

  alias UAInspector.Database.VendorFragments

  @behaviour UAInspector.Parser

  def parse(ua), do: parse(ua, VendorFragments.list())

  defp parse(_, []), do: :unknown

  defp parse(ua, [{_index, {brand, regex}} | database]) do
    if Regex.match?(regex, ua) do
      brand
    else
      parse(ua, database)
    end
  end
end
