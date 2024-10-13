defmodule UAInspectorVerify.Verify.Custom do
  @moduledoc """
  Verify a custom fixture against a result.
  """

  def verify(%{client: _} = testcase, %{client: _} = result) do
    testcase.user_agent == result.user_agent &&
      testcase.browser_family == result.browser_family &&
      testcase.os_family == result.os_family &&
      testcase.client == maybe_from_struct(result.client) &&
      testcase.device == maybe_from_struct(result.device) &&
      testcase.os == maybe_from_struct(result.os)
  end

  defp maybe_from_struct(:unknown), do: :unknown
  defp maybe_from_struct(result), do: Map.from_struct(result)
end
