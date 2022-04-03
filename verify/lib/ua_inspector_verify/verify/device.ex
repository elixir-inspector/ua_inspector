defmodule UAInspectorVerify.Verify.Device do
  @moduledoc false

  def verify(%{device: testcase}, result) do
    testcase.brand == result.brand &&
      testcase.model == result.model &&
      testcase.type == result.type
  end
end
