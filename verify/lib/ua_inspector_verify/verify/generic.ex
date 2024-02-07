defmodule UAInspectorVerify.Verify.Generic do
  @moduledoc """
  Verify a generic fixture against a result.
  """

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 11; sohKwhigbQ; U; en) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.101 Mobile AvastSecureBrowser/6.6.0 Build/3850 Safari/537.36",
          device: %{type: "tablet"} = device
        } = testcase,
        result
      ) do
    # detected as "tablet" in default remote release
    # detected as "smartphone" in upcoming remove release
    verify(
      %{testcase | device: %{device | type: "smartphone"}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; U; Android 4.0.4; fa-ir) AppleWebKit/534.35 (KHTML, like Gecko)  Chrome/11.0.696.65 Safari/534.35 Puffin/2.10990AP Mobile",
          device: %{type: "tablet"} = device
        } = testcase,
        result
      ) do
    # detected as "tablet" in default remote release
    # detected as "smartphone" in upcoming remove release
    verify(
      %{testcase | device: %{device | type: "smartphone"}},
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
