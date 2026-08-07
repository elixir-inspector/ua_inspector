defmodule UAInspectorVerify.Verify.OS do
  @moduledoc false

  def verify(%{os: testcase}, result) do
    testcase.name == result.name &&
      testcase.platform == result.platform &&
      testcase.version == result.version
  end
end
