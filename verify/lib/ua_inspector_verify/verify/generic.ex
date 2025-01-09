defmodule UAInspectorVerify.Verify.Generic do
  @moduledoc """
  Verify a generic fixture against a result.
  """

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36 AlohaBrowser/5.10.4",
          browser_family: :unknown
        } = testcase,
        %{browser_family: "Chrome" = browser_family} = result
      ) do
    # improved browser family detection in upcoming remote release
    verify(
      %{testcase | browser_family: browser_family},
      result
    )
  end

  def verify(
        %{
          client:
            %{engine: "Blink", engine_version: wrong_version, version: correct_version} = client
        } = testcase,
        %{client: %{engine: "Blink", engine_version: correct_version, version: correct_version}} =
          result
      )
      when wrong_version != correct_version do
    # improved engine version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: correct_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36 AlohaBrowser/5.10.4",
          client: %{engine: "Blink", engine_version: "123.0.0.0", version: "5.10.4"} = client
        } = testcase,
        %{
          client: %{
            engine: "Blink",
            engine_version: "123.0.6312.118" = remote_engine_version,
            version: "5.10.4"
          }
        } =
          result
      ) do
    # improved engine version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: remote_engine_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
          client: %{engine: "Blink", engine_version: "122.0.0.0", version: :unknown} = client
        } = testcase,
        %{
          client: %{
            engine: "Blink",
            engine_version: "122.0.6261.119" = remote_engine_version,
            version: :unknown
          }
        } =
          result
      ) do
    # improved engine version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: remote_engine_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36",
          client: %{engine: "Blink", engine_version: "123.0.0.0", version: :unknown} = client
        } = testcase,
        %{
          client: %{
            engine: "Blink",
            engine_version: "123.0.6312.99" = remote_engine_version,
            version: :unknown
          }
        } =
          result
      ) do
    # improved engine version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: remote_engine_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
          client: %{engine: "Blink", engine_version: "125.0.0.0", version: :unknown} = client
        } = testcase,
        %{
          client: %{
            engine: "Blink",
            engine_version: "125.0.6422.165" = remote_engine_version,
            version: :unknown
          }
        } =
          result
      ) do
    # improved engine version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: remote_engine_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36",
          client: %{engine: "Blink", engine_version: "126.0.0.0", version: :unknown} = client
        } = testcase,
        %{
          client: %{
            engine: "Blink",
            engine_version: "126.0.6478.186" = remote_engine_version,
            version: :unknown
          }
        } =
          result
      ) do
    # improved engine version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: remote_engine_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; XK03H Build/QX; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/126.0.6478.133 YaBrowser/24.1.2.221 (lite) TV Safari/537.36",
          device: %{type: "tv"} = device
        } = testcase,
        result
      ) do
    # detected as "tv" in default remote release
    # detected as "peripheral" in upcoming remote release
    verify(
      %{testcase | device: %{device | type: "peripheral"}},
      result
    )
  end

  def verify(
        %{device: %{type: testcase_device_type} = testcase_device, os: %{name: "KaiOS"}} =
          testcase,
        result
      )
      when testcase_device_type != "feature phone" do
    # improved device type detection in upcoming remote release
    verify(
      %{testcase | device: %{testcase_device | type: "feature phone"}},
      result
    )
  end

  def verify(%{device: :unknown, os: %{name: "KaiOS"}} = testcase, result) do
    # improved device type detection in upcoming remote release
    verify(
      %{testcase | device: %{brand: :unknown, model: :unknown, type: "feature phone"}},
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
