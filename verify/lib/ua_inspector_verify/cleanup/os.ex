defmodule UAInspectorVerify.Cleanup.OS do
  @moduledoc false

  alias UAInspectorVerify.Cleanup.Base

  @empty_to_unknown [
    [:os, :name],
    [:os, :version],
    [:os, :platform]
  ]

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> Base.empty_to_unknown(@empty_to_unknown)
    |> version_to_string()
  end

  defp version_to_string(%{os: %{version: version}} = testcase) when is_integer(version) do
    put_in(testcase, [:os, :version], to_string(version))
  end

  defp version_to_string(testcase), do: testcase
end
