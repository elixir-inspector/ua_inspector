defmodule UAInspectorVerify.Verify.TypeMethods do
  @moduledoc false

  def verify(%{check: [bot?, mobile?, desktop?, tablet?, tv?, wearable?]}, result) do
    bot? == UAInspector.bot?(result) &&
      mobile? == UAInspector.mobile?(result) &&
      desktop? == UAInspector.desktop?(result) &&
      verify_type("tablet", tablet?, result) &&
      verify_type("tv", tv?, result) &&
      verify_type("wearable", wearable?, result)
  end

  defp verify_type(type, true, %{device: %{type: type}}), do: true
  defp verify_type(type, false, %{device: %{type: type}}), do: false
  defp verify_type(_, _, _), do: true
end
