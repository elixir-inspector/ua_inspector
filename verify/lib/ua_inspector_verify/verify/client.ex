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
            "Mozilla/5.0 (Linux; Andr0id 11; TY55_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.56 Safari/537.36 OMI/4.24.3.23.StableAVB_Telly.1",
          client: %{version: "4.24"} = client
        } = testcase,
        %{version: "4.24.3.23" = remote_version} = result
      ) do
    # improved version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | version: remote_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; NetCast; U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.128 Safari/537.36 SmartTV/10.0 Colt/2.0",
          client: %{version: "94"} = client
        } = testcase,
        %{version: "94.0.4606.128" = remote_version} = result
      ) do
    # improved version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | version: remote_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.132 Safari/537.36",
          client: %{version: "98"} = client
        } = testcase,
        %{version: "98.0.4758.132" = remote_version} = result
      ) do
    # improved version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | version: remote_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Mobile Safari/537.36",
          client: %{version: "106"} = client
        } = testcase,
        %{version: "106.0.0.0" = remote_version} = result
      ) do
    # improved version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | version: remote_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/111.0.0.0 Safari/537.36",
          client: %{version: "111"} = client
        } = testcase,
        %{version: "111.0.0.0" = remote_version} = result
      ) do
    # improved version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | version: remote_version}},
      result
    )
  end

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
          client: %{version: "122"} = client
        } = testcase,
        %{version: "122.0.0.0" = remote_version} = result
      ) do
    # improved version detection in upcoming remote release
    verify(
      %{testcase | client: %{client | version: remote_version}},
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
