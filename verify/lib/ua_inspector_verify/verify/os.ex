defmodule UAInspectorVerify.Verify.OS do
  @moduledoc false

  def verify(
        %{
          user_agent: "Mozilla/4.77 [en] (X11; I; IRIX;64 6.5 IP30)",
          os: %{name: "IRIX", platform: :unknown} = os
        } = testcase,
        %{platform: "x64" = result_platform} = result
      ) do
    # improved detection in upcoming remote release
    verify(
      %{testcase | os: %{os | platform: result_platform}},
      result
    )
  end

  def verify(%{os: testcase}, result) do
    testcase.name == result.name &&
      testcase.platform == result.platform &&
      testcase.version == result.version
  end
end
