defmodule UAInspectorVerify.Cleanup.VendorFragment do
  @moduledoc false

  alias UAInspectorVerify.Cleanup.Base

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(%{useragent: ua} = testcase) do
    testcase
    |> Base.prepare_headers()
    |> Map.delete(:useragent)
    |> Map.put(:user_agent, ua)
  end
end
