defmodule UAInspector.Util.UserAgent do
  @moduledoc false

  alias UAInspector.ClientHints
  alias UAInspector.Util

  @doc """
  Returns if the parsed UA contains the 'Windows NT;' or 'X11; Linux x86_64' fragments
  """
  @spec has_desktop_fragment?(String.t()) :: boolean
  def has_desktop_fragment?(ua) do
    re_desktop_pos = Util.Regex.build_regex("(?:Windows (?:NT|IoT)|X11; Linux x86_64)")

    re_desktop_neg =
      Util.Regex.build_regex(
        "CE-HTML| Mozilla/|Andr[o0]id|Tablet|Mobile|iPhone|Windows Phone|ricoh|OculusBrowser|PicoBrowser|Lenovo|compatible; MSIE|Trident/|Tesla/|XBOX|FBMD/|ARM; ?([^)]+)"
      )

    Regex.match?(re_desktop_pos, ua) && !Regex.match?(re_desktop_neg, ua)
  end

  @doc """
  Returns if the parsed UA contains the 'Android 10 K;' or Android 10 K Build/` fragment
  """
  @spec has_client_hints_fragment?(String.t()) :: boolean
  def has_client_hints_fragment?(ua),
    do: Regex.match?(~r"Android (?:10[.\d]*; K(?: Build/|[;)])|1[1-5]\)) AppleWebKit"i, ua)

  @doc """
  Patch "frozen" user agents for improved detection.
  """
  @spec restore_from_client_hints(String.t(), ClientHints.t() | nil) :: String.t()
  def restore_from_client_hints(ua, client_hints) do
    ua
    |> restore_android(client_hints)
    |> restore_desktop(client_hints)
  end

  defp restore_android(ua, %{model: model, platform_version: platform_version})
       when is_binary(model) do
    if Util.UserAgent.has_client_hints_fragment?(ua) do
      os_version =
        case platform_version do
          :unknown -> "10"
          "" -> "10"
          _ -> platform_version
        end

      Regex.replace(
        ~r/(Android (?:10[.\d]*; K|1[1-5]))/,
        ua,
        "Android #{os_version}; #{model}"
      )
    else
      ua
    end
  end

  defp restore_android(ua, _), do: ua

  defp restore_desktop(ua, %{model: model}) when is_binary(model) do
    if Util.UserAgent.has_desktop_fragment?(ua) do
      Regex.replace(
        ~r/(X11; Linux x86_64)/,
        ua,
        "X11; Linux x86_64; #{model}"
      )
    else
      ua
    end
  end

  defp restore_desktop(ua, _), do: ua
end
