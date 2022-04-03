defmodule UAInspectorVerify.Cleanup.Device do
  @moduledoc false

  alias UAInspectorVerify.Cleanup.Base

  @empty_to_unknown [
    [:device, :model]
  ]

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> Base.empty_to_unknown(@empty_to_unknown)
  end
end
