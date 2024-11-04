defmodule UAInspector.Util.UserAgent do
  @moduledoc false

  @client_hints_fragment Regex.compile!(
                           "Android (?:10[.\d]*; K(?: Build/|[;)])|1[1-5]\\)) AppleWebKit",
                           [:caseless]
                         )

  @doc """
  Returns if the parsed UA contains the 'Android 10 K;' or Android 10 K Build/` fragment
  """
  @spec has_client_hints_fragment?(String.t()) :: boolean
  def has_client_hints_fragment?(ua), do: Regex.match?(@client_hints_fragment, ua)
end
