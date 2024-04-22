defmodule UAInspectorVerify.Verify.Generic do
  @moduledoc """
  Verify a generic fixture against a result.
  """

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/21B101 [FBAN/FBIOS;FBAV/445.0.0.35.117;FBBV/548375166;FBDV/iPhone12,1;FBMD/iPhone;FBSN/iOS;FBSV/17.1.2;FBSS/2;FBID/phone;FBLC/es_LA;FBOP/5;FBRV/550068703]",
          headers: %{"sec-ch-ua-brands" => _}
        },
        _result
      ) do
    # header format in fixture currently not parsed
    true
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (iPhone; CPU iPhone OS 13_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/79.0.3945.73 Mobile/15E148 Safari/604.1",
          headers: %{"sec-ch-ua-brands" => _}
        },
        _result
      ) do
    # header format in fixture currently not parsed
    true
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
