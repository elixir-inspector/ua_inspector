defmodule UAInspectorVerify.Verify.Client do
  @moduledoc false

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Mobile Alva/113.0.0.0 Mobile Safari/537.36",
          client: %{name: "ALVA", version: "113.0.0.0"} = client
        } = testcase,
        %{version: "113.0.5643.0" = result_version} = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{testcase | client: %{client | version: result_version}},
      result
    )
  end

  def verify(
        %{
          user_agent: "Dalvik/2.1.0 (Linux; U; Android 11; SM-A705MN Build/RP1A.200720.012)",
          client: %{name: "Chrome Webview", engine: :unknown, engine_version: :unknown} = client
        } = testcase,
        %{
          engine: "Blink" = result_engine,
          engine_version: "117.0.5938.140" = result_engine_version
        } = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{
        testcase
        | client: %{client | engine: result_engine, engine_version: result_engine_version}
      },
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.200",
          client: %{name: "Edge WebView", engine: :unknown, engine_version: :unknown} = client
        } = testcase,
        %{
          engine: "Blink" = result_engine,
          engine_version: "115.0.5790.171" = result_engine_version
        } = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{
        testcase
        | client: %{client | engine: result_engine, engine_version: result_engine_version}
      },
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 15; SM-S911B Build/AP3A.240905.015.A2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.7339.155 Mobile Safari/537.36",
          client: %{name: "Opera GX", engine: :unknown, engine_version: :unknown} = client
        } = testcase,
        %{
          engine: "Blink" = result_engine,
          engine_version: "140.0.7339.155" = result_engine_version
        } = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{
        testcase
        | client: %{client | engine: result_engine, engine_version: result_engine_version}
      },
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
          client: %{name: "Vivaldi", engine_version: "114.0.0.0"} = client
        } = testcase,
        %{engine_version: "114.0.5735.245" = result_engine_version} = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: result_engine_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 YaSearchBrowser/24.10.0 Mobile Safari/537.36",
          client: %{name: "Yandex Browser", engine_version: "120.0.0.0"} = client
        } = testcase,
        %{engine_version: "120.0.6099.234" = result_engine_version} = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: result_engine_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36",
          client: %{name: "Blazer", version: "140.0.0.0"} = testcase_client
        } = testcase,
        result
      ) do
    # needs clarification whether first or second client hint "Blazer" version is correct
    verify(%{testcase | client: %{testcase_client | version: "3"}}, result)
  end

  def verify(
        %{
          user_agent:
            "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 10.0; Win64; x64; Anonymisiert durch AlMiSoft Browser-Maulkorb 39663422; Trident/7.0; .NET4.0C; .NET4.0E; .NET CLR 2.0.50727; .NET CLR 3.0.30729; .NET CLR 3.5.30729; Tablet PC 2.0; Browzar)"
        },
        _result
      ) do
    # requires mobile app parsing to be skipped
    # fixture is pure browser parser result
    true
  end

  def verify(
        %{user_agent: "Mozilla/5.0 (X11; Linux x86_64; rv:21.0) Gecko/20100101 SlimerJS/0.7"},
        _result
      ) do
    # requires library only client parsing
    true
  end

  def verify(%{client: %{engine: _} = testcase}, result) do
    testcase.name == result.name &&
      testcase.type == result.type &&
      testcase.version == result.version &&
      testcase.engine == result.engine &&
      testcase.engine_version == result.engine_version
  end

  def verify(%{client: testcase}, result) do
    testcase.name == result.name &&
      testcase.type == result.type &&
      testcase.version == result.version
  end
end
