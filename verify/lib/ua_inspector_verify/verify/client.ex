defmodule UAInspectorVerify.Verify.Client do
  @moduledoc false

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

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0",
          client: %{engine: :unknown, name: "TV-Browser Internet"} = client
        } = testcase,
        %{engine: "Blink" = remote_engine} = result
      ) do
    # improved engine detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine: remote_engine}},
      result
    )
  end

  def verify(
        %{
          client:
            %{engine: "Blink", engine_version: wrong_version, version: correct_version} = client
        } = testcase,
        %{engine: "Blink", engine_version: correct_version, version: correct_version} = result
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
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36 Presearch (Tempest)",
          client: %{engine_version: "123.0.0.0", version: :unknown} = client
        } = testcase,
        %{engine_version: "123.0.6312.121" = remote_engine_version, version: :unknown} =
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
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Mobile Alva/113.0.0.0 Mobile Safari/537.36",
          client: %{engine_version: "113.0.0.0", version: "113.0.0.0"} = client
        } = testcase,
        %{engine_version: "113.0.5643.0" = remote_engine_version, version: "113.0.0.0"} =
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
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 YaBrowser/23.3.1.895 Yowser/2.5 Safari/537.36",
          client: %{engine_version: "110.0.0.0", version: "23.3.1.895"} = client
        } = testcase,
        %{engine_version: "110.0.5481.208" = remote_engine_version, version: "23.3.1.895"} =
          result
      ) do
    # improved engine version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | engine_version: remote_engine_version}},
      result
    )
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
