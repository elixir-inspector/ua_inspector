defmodule UAInspector.Util.ClientHintMapping do
  @moduledoc false

  alias UAInspector.ShortCodeMap.ClientHintBrowserMapping
  alias UAInspector.ShortCodeMap.ClientHintOSMapping

  @doc """
  Returns the mapped browser name or the input value if unmapped.
  """
  @spec browser_mapping(browser :: String.t()) :: String.t()
  def browser_mapping(browser) do
    mapped =
      browser
      |> String.downcase()
      |> find_mapping(ClientHintBrowserMapping.list())

    mapped || browser
  end

  @doc """
  Returns the mapped OS name or the input value if unmapped.
  """
  @spec os_mapping(os :: String.t()) :: String.t()
  def os_mapping(os) do
    mapped =
      os
      |> String.downcase()
      |> find_mapping(ClientHintOSMapping.list())

    mapped || os
  end

  defp find_mapping(_, []), do: nil

  defp find_mapping(value, [{mapped, values} | mappings]) do
    if value in values do
      mapped
    else
      find_mapping(value, mappings)
    end
  end
end
