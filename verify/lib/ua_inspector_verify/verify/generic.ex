defmodule UAInspectorVerify.Verify.Generic do
  @moduledoc """
  Verify a generic fixture against a result.
  """

  @unknown_agents [
    "Dalvik/2.1.0 (Linux; U; Android 8.1.0; Armor_3 Build/O11019)",
    "Mozilla/5.0 (Linux; Android 10; Armadillo Phone) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.81 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor 10 5G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor 11 5G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.88 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.105 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor 7E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor 9E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.86 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor X5 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.86 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor X7 Build/QP1A.190711.020) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/87.0.4280.66 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor X7 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.86 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 10; Armor X8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Armor 11T 5G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.62 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Armor 12 5G) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.98 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Armor 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Armor X10 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.85 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Armor X8i) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.41 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Armor X9 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.87 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Armor X9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.210 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 11; Power Armor 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Armor 12S) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Armor 15) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.88 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Armor 17 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Armor 20WT) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Armor X6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Power Armor 16 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Power Armor 18T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Power Armor 19) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Power Armor 19T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.5481.192 Mobile Safari/537.36 OPR/74.3.3922.71982",
    "Mozilla/5.0 (Linux; Android 12; Power Armor X11 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 12; Power Armor14 Pro Build/SP1A.210812.016; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/101.0.4951.61 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 13; Armor 24) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 13; Armor X12 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 13; Armor X13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 13; Armor_C1w Build/TP1A.220624.014; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/124.0.6367.123 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 4.4.4; SANTIN #Armor) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.143 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 5.1.1; SANTIN Armor 2 Build/LMY47V) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/39.0.0.0 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 6.0; Armor Build/MRA58K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.107 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 7.0; Armor_2 Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/58.0.3029.83 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/147.0.0.44.75;]",
    "Mozilla/5.0 (Linux; Android 7.0; Armor_2S) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.93 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 8.0.0; SM-G930W8 Build/R16NW; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/102.0.5005.125 Mobile Safari/537.36 GoogleApp/13.22.15.26.arm6",
    "Mozilla/5.0 (Linux; Android 8.1.0; Armor_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 8.1.0; Armor_X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 8.1.0; Armor_X2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; Armor 5S) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; Armor X5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; Armor_3W) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.99 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; Armor_3WT) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.99 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; Armor_6E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.127 Mobile Safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; Armor_6S) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Mobile Safari/537.36",
    "mozilla/5.0 (linux; android 9; armor_7) applewebkit/537.36 (khtml, like gecko) chrome/83.0.4103.106 mobile safari/537.36",
    "Mozilla/5.0 (Linux; Android 9; Armor_X3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.111 Mobile Safari/537.36",
    "mozilla/5.0 (linux; android 9; armor_x6) applewebkit/537.36 (khtml, like gecko) chrome/83.0.4103.106 mobile safari/537.36",
    "Mozilla/5.0 (Linux; U; Android 11; ru; Power Armor 13 Build/RP1A.200720.011) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/57.0.2987.108 UCBrowser/12.10.0.1163 UCTurbo/1.10.3.900 Mobile Safari/537.36"
  ]

  def verify(
        %{user_agent: user_agent, os: %{platform: "ARM"} = os} = testcase,
        %{os: %{platform: :unknown}} = result
      )
      when user_agent in @unknown_agents do
    # detected as "ARM" in default remote release
    # detected as "unknown" in upcoming remote release
    verify(
      %{testcase | os: %{os | platform: :unknown}},
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
