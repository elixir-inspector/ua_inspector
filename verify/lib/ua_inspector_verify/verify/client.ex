defmodule UAInspectorVerify.Verify.Client do
  @moduledoc false

  def verify(%{client: testcase}, result) do
    testcase.name == result.name &&
      testcase.type == result.type &&
      testcase.version == result.version
  end
end
