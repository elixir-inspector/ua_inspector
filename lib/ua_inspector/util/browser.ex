defmodule UAInspector.Util.Browser do
  @moduledoc false

  alias UAInspector.ShortCodeMap

  @doc """
  Returns the browser family for a browser.

  Unknown browsers return `nil` as their family.
  """
  @spec family(browser :: String.t()) :: String.t() | nil
  def family(browser) do
    browser
    |> ShortCodeMap.ClientBrowsers.to_short()
    |> family(ShortCodeMap.BrowserFamilies.list())
  end

  defp family(_, []), do: nil

  defp family(short_code, [{name, short_codes} | families]) do
    if short_code in short_codes do
      name
    else
      family(short_code, families)
    end
  end
end
