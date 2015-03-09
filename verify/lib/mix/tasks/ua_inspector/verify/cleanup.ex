defmodule Mix.Tasks.UAInspector.Verify.Cleanup do
  @moduledoc """
  Cleans up testcases.
  """

  alias UAInspector.ShortCode

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> cleanup_client()
    |> cleanup_client_version()
    |> cleanup_os_version()
    |> remove_os_short_name()
    |> unshorten_device_brand()
  end


  defp cleanup_client(%{ client: client } = testcase) do
    client =
         client
      |> Map.delete(:engine)
      |> Map.delete(:short_name)

    %{ testcase | client: client }
  end


  defp cleanup_client_version(%{ client: %{ version: :null }} = testcase) do
    put_in(testcase, [ :client, :version ], :unknown)
  end
  defp cleanup_client_version(%{ client: %{ version: version }} = testcase) do
    put_in(testcase, [ :client, :version ], to_string(version))
  end
  defp cleanup_client_version(testcase), do: testcase


  defp cleanup_os_version(%{ os: %{ version: :null }} = testcase) do
    put_in(testcase, [ :os, :version ], :unknown)
  end
  defp cleanup_os_version(%{ os: %{ version: version }} = testcase) do
    put_in(testcase, [ :os, :version ], to_string(version))
  end
  defp cleanup_os_version(testcase), do: testcase


  defp remove_os_short_name(testcase) do
    %{ testcase | os: Map.delete(testcase.os, :short_name) }
  end


  def unshorten_device_brand(%{ device: %{ brand: brand }} = testcase) do
    put_in(testcase,[ :device, :brand ], ShortCode.device_brand(brand, :long))
  end
  def unshorten_device_brand(testcase), do: testcase
end
