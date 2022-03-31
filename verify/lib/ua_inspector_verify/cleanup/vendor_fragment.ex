defmodule UAInspectorVerify.Cleanup.VendorFragment do
  @moduledoc false

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(%{useragent: ua} = testcase) do
    Map.put(testcase, :user_agent, ua)
  end
end
