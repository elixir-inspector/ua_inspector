defmodule UAInspectorVerify.Verify.Client do
  @moduledoc false

  def verify(%{headers: %{"x-requested-with" => _}, client: testcase}, result) do
    testcase.name == result.name &&
      testcase.type == result.type &&
      testcase.version == result.version
  end

  def verify(%{headers: _}, _), do: true

  def verify(%{client: testcase}, result) do
    testcase.name == result.name &&
      testcase.type == result.type &&
      testcase.version == result.version
  end
end
