defmodule UAInspectorVerify.Verify.VendorFragment do
  @moduledoc false

  def verify(%{vendor: testcase}, result) do
    testcase == result
  end
end
