defmodule UAInspectorVerify.Verify.OS do
  @moduledoc false

  def verify(
        %{
          user_agent:
            "Mozilla/5.0 (Linux; Android 10; SM-A105F Build/Lineage_17.1-arm64_by_Eureka_Team; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/87.0.4280.101 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/399.0.0.24.93;]",
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

  def verify(%{os: testcase}, result) do
    testcase.name == result.name &&
      testcase.platform == result.platform &&
      testcase.version == result.version
  end
end
