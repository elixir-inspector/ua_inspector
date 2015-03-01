defmodule Mix.Tasks.Ua_inspector.Verify.Unshortener do
  @moduledoc """
  Replaces shortcodes in testcases with their full values.
  """

  def parse(testcase) do
    %{ testcase | device: parse_device(testcase.device) }
  end

  defp parse_device(device) do
    %{ device | brand: unshorten(device.brand) }
  end


  defp unshorten("TA"), do: "Tesla"
  defp unshorten(brand), do: brand
end
