defmodule UAInspectorVerify.Verify.OS do
  @moduledoc false

  def verify(
        %{
          user_agent: "python-requests/2.7.0 CPython/2.7.15 Linux/4.16.0-kali2-amd64",
          os: %{platform: :unknown} = testcase_os
        } = testcase,
        %{platform: "x64" = remote_platform} = result
      ) do
    # improved platform detection in upcoming remote release
    verify(
      %{testcase | os: %{testcase_os | platform: remote_platform}},
      result
    )
  end

  def verify(%{os: testcase}, result) do
    testcase.name == result.name &&
      testcase.platform == result.platform &&
      testcase.version == result.version
  end
end
