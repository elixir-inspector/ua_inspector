defmodule UAInspector.Parser.VendorFragment do
  @moduledoc false

  alias UAInspector.Database.VendorFragments

  @behaviour UAInspector.Parser.Behaviour

  @impl UAInspector.Parser.Behaviour
  def parse(ua, _), do: do_parse(ua, VendorFragments.list())

  defp do_parse(_, []), do: :unknown

  defp do_parse(ua, [{regex, brand} | database]) do
    if Regex.match?(regex, ua) do
      brand
    else
      do_parse(ua, database)
    end
  end
end
