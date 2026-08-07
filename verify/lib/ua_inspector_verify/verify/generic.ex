defmodule UAInspectorVerify.Verify.Generic do
  @moduledoc """
  Verify a generic fixture against a result.
  """

  def verify(
        %{
          user_agent: "",
          client:
            %{name: "Avast Secure Browser", engine_version: :unknown, engine: :unknown} = client
        } = testcase,
        %{
          client: %{
            engine: "Blink" = result_client_engine,
            engine_version: "98.0.4758.101" = result_client_engine_version
          }
        } = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{
        testcase
        | client: %{
            client
            | engine: result_client_engine,
              engine_version: result_client_engine_version
          }
      },
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/24.0 Chrome/117.0.0.0 Mobile Safari/537.36",
          client:
            %{name: "Samsung Browser", engine_version: "117.0.0.0", version: "24.0"} = client
        } = testcase,
        %{
          client: %{
            engine_version: "117.0.5938.156" = result_client_engine_version,
            version: "24.0.7.1" = result_client_version
          }
        } = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{
        testcase
        | client: %{
            client
            | engine_version: result_client_engine_version,
              version: result_client_version
          }
      },
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
