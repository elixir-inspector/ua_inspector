defmodule UAInspectorVerify.Verify.Generic do
  @moduledoc """
  Verify a generic fixture against a result.
  """

  def verify(
        %{
          user_agent:
            "Anytime/1.3.3 b95 (phone;android sdk_gphone64_arm64-userdebug 13 TE1A.220922.012 9302419 dev-keys) https://github.com/amugofjava/anytime_podcast_player",
          os: %{platform: :unknown} = os
        } = testcase,
        result
      ) do
    # detected as "unknown" in default remote release
    # detected as "ARM" in upcoming remote release
    verify(
      %{testcase | os: %{os | platform: "ARM"}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; U; Android 4.0.4; es-es; tablet Fnac 10 3G Build/1.1.11-1015 20130125-16:17) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Safari/534.30",
          device: :unknown
        } = testcase,
        result
      ) do
    # detected as "unknown" in default remote release
    # detected as "tablet" in upcoming remote release
    verify(
      %{testcase | device: %{brand: :unknown, model: :unknown, type: "tablet"}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (X11; U; Linux armv7l; en-GB; rv:1.9.2a1pre) Gecko/20090514 Firefox/3.0 Tablet browser 0.9.7 RX-34",
          device: %{type: "desktop"} = device
        } = testcase,
        result
      ) do
    # detected as "desktop" in default remote release
    # detected as "tablet" in upcoming remote release
    verify(
      %{testcase | device: %{device | type: "tablet"}},
      result
    )
  end

  def verify(%{client: _} = testcase, %{client: _} = result) do
    # regular user agent
    testcase.user_agent == result.user_agent &&
      testcase.browser_family == result.browser_family &&
      testcase.os_family == result.os_family &&
      testcase.client == maybe_from_struct(result.client) &&
      testcase.device == maybe_from_struct(result.device) &&
      testcase.os == maybe_from_struct(result.os)
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def verify(testcase, result) do
    # bot
    acc = testcase.user_agent == result.user_agent && testcase.bot.name == result.name

    acc =
      if Map.has_key?(testcase.bot, :category) do
        acc && testcase.bot.category == result.category
      else
        acc
      end

    acc =
      if Map.has_key?(testcase.bot, :url) do
        acc && testcase.bot.url == result.url
      else
        acc
      end

    acc =
      if Map.has_key?(testcase.bot, :producer) do
        acc && testcase.bot.producer == maybe_from_struct(result.producer)
      else
        acc
      end

    acc
  end

  defp maybe_from_struct(:unknown), do: :unknown
  defp maybe_from_struct(result), do: Map.from_struct(result)
end
