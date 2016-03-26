defmodule UAInspector.Util.Client do
  @moduledoc """
  Utility methods for client lookups.
  """

  alias UAInspector.ShortCodeMap

  @doc """
  Checks whether a client browser is treated as "mobile only".
  """
  @spec mobile_only?(client :: map | :unkonwn) :: boolean
  def mobile_only?(%{ name: name }) do
    short_code = name |> ShortCodeMap.ClientBrowsers.to_short()

    Enum.any? ShortCodeMap.MobileBrowsers.list, &( &1 == { short_code })
  end

  def mobile_only?(_), do: false
end
