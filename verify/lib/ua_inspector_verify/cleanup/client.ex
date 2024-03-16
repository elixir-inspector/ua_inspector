defmodule UAInspectorVerify.Cleanup.Client do
  @moduledoc false

  alias UAInspectorVerify.Cleanup.Base

  @empty_to_unknown [
    [:client, :engine],
    [:client, :engine_version],
    [:client, :version]
  ]

  @version_to_string [
    [:client, :version]
  ]

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> Base.empty_to_unknown(@empty_to_unknown)
    |> Base.prepare_headers()
    |> Base.version_to_string(@version_to_string)
  end
end
