defmodule UAInspectorVerify.Verify.OS do
  @moduledoc false

  @unknown_agents [
    "Mozilla/5.0 (Linux; Android 10; Armadillo Phone) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.81 Mobile Safari/537.36"
  ]

  def verify(
        %{user_agent: user_agent, os: %{platform: "ARM"} = os} = testcase,
        %{platform: :unknown} = result
      )
      when user_agent in @unknown_agents do
    # detected as "ARM" in default remote release
    # detected as "unknown" in upcoming remote release
    verify(
      %{testcase | os: %{os | platform: :unknown}},
      result
    )
  end

  def verify(%{os: testcase}, result) do
    testcase.name == result.name &&
      testcase.platform == result.platform &&
      testcase.version == result.version
  end
end
