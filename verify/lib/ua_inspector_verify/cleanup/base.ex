defmodule UAInspectorVerify.Cleanup.Base do
  @moduledoc false

  def empty_to_unknown(testcase, []), do: testcase

  def empty_to_unknown(testcase, [path | paths]) do
    testcase
    |> get_in(path)
    |> case do
      :null -> put_in(testcase, path, :unknown)
      "" -> put_in(testcase, path, :unknown)
      _ -> testcase
    end
    |> empty_to_unknown(paths)
  rescue
    FunctionClauseError -> empty_to_unknown(testcase, paths)
  end

  def version_to_string(testcase, []), do: testcase

  def version_to_string(testcase, [path | paths]) do
    testcase
    |> get_in(path)
    |> case do
      version when is_integer(version) -> put_in(testcase, path, to_string(version))
      _ -> testcase
    end
    |> version_to_string(paths)
  rescue
    FunctionClauseError -> version_to_string(testcase, paths)
  end
end
