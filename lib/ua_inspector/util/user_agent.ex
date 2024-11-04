defmodule UAInspector.Util.UserAgent do
  @moduledoc false

  alias UAInspector.Util

  @client_hints_fragment Regex.compile!(
                           "Android (?:10[.\d]*; K(?: Build/|[;)])|1[1-5]\\)) AppleWebKit",
                           [:caseless]
                         )

  @desktop_pos Util.Regex.build_regex("(?:Windows (?:NT|IoT)|X11; Linux x86_64)")
  @desktop_neg Util.Regex.build_regex(
                 "CE-HTML| Mozilla/|Andr[o0]id|Tablet|Mobile|iPhone|Windows Phone|ricoh|OculusBrowser|PicoBrowser|Lenovo|compatible; MSIE|Trident/|Tesla/|XBOX|FBMD/|ARM; ?([^)]+)"
               )

  @doc """
  Returns if the parsed UA contains the 'Windows NT;' or 'X11; Linux x86_64' fragments
  """
  @spec has_desktop_fragment?(String.t()) :: boolean
  def has_desktop_fragment?(ua),
    do: Regex.match?(@desktop_pos, ua) && !Regex.match?(@desktop_neg, ua)

  @doc """
  Returns if the parsed UA contains the 'Android 10 K;' or Android 10 K Build/` fragment
  """
  @spec has_client_hints_fragment?(String.t()) :: boolean
  def has_client_hints_fragment?(ua), do: Regex.match?(@client_hints_fragment, ua)
end
