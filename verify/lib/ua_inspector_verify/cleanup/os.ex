defmodule UAInspectorVerify.Cleanup.OS do
  @moduledoc false

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
    |> convert_empty(@empty_to_unknown, :unknown)
    |> version_to_string()
  end

  defp convert_empty(testcase, [], _), do: testcase

  defp convert_empty(testcase, [path | paths], replacement) do
    testcase
    |> get_in(path)
    |> case do
      :null -> put_in(testcase, path, replacement)
      "" -> put_in(testcase, path, replacement)
      _ -> testcase
    end
    |> convert_empty(paths, replacement)
  rescue
    FunctionClauseError -> convert_empty(testcase, paths, replacement)
  end

  defp version_to_string(%{os: %{version: version}} = testcase) when is_integer(version) do
    put_in(testcase, [:os, :version], to_string(version))
  end

  defp version_to_string(testcase), do: testcase
end
