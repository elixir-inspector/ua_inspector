defmodule UAInspector.Util.Client do
  @moduledoc false

  alias UAInspector.Result
  alias UAInspector.ShortCodeMap

  @doc """
  Checks whether a client browser is treated as "mobile only".
  """
  @spec mobile_only?(client :: Result.Client.t() | :unknown) :: boolean
  def mobile_only?(%{name: name}) do
    ShortCodeMap.ClientBrowsers.to_short(name) in ShortCodeMap.MobileBrowsers.list()
  end

  def mobile_only?(_), do: false
end
