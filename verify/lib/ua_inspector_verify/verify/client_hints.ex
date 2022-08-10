defmodule UAInspectorVerify.Verify.ClientHints do
  @moduledoc false

  def verify(%{client: %{name: "iDesktop PC Browser"}}, _) do
    # requires browser client hint parsing
    true
  end

  def verify(testcase, result) do
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
