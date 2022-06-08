defmodule UAInspectorVerify.Cleanup.VendorFragment do
  @moduledoc false

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(%{useragent: ua} = testcase) do
    testcase
    |> Map.delete(:useragent)
    |> Map.put(:user_agent, ua)
  end
end
