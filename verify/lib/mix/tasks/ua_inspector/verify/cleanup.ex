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
    |> cleanup_client_engine()
    |> cleanup_client_version()
    |> cleanup_device_brand()
    |> cleanup_device_model()
    |> cleanup_os_entry()
    |> cleanup_os_version()
    |> remove_client_short_name()
    |> remove_os_short_name()
    |> unshorten_device_brand()
  end


  defp cleanup_client_engine(%{ client: %{ engine: :null }} = testcase) do
    put_in(testcase, [ :client, :engine ], :unknown)
  end
  defp cleanup_client_engine(%{ client: :null } = testcase) do
    %{ testcase | client: :unknown }
  end
  defp cleanup_client_engine(%{ client: client } = testcase) do
    if not Map.has_key?(client, :engine) do
      client = Map.put(client, :engine, :unknown)
    end

    %{ testcase | client: client }
  end


  defp cleanup_client_version(%{ client: %{ version: :null }} = testcase) do
    put_in(testcase, [ :client, :version ], :unknown)
  end
  defp cleanup_client_version(testcase), do: testcase


  defp cleanup_device_brand(%{ device: %{ brand: :null }} = testcase) do
    put_in(testcase, [ :device, :brand ], :unknown)
  end
  defp cleanup_device_brand(testcase), do: testcase


  defp cleanup_device_model(%{ device: %{ model: :null }} = testcase) do
    put_in(testcase, [ :device, :model ], :unknown)
  end
  defp cleanup_device_model(testcase), do: testcase


  defp cleanup_os_entry(%{ os: os } = testcase) do
    if [] == Map.keys(os) do
      os = :unknown
    end

    %{ testcase | os: os }
  end


  defp cleanup_os_version(%{ os: %{ version: :null }} = testcase) do
    put_in(testcase, [ :os, :version ], :unknown)
  end
  defp cleanup_os_version(testcase), do: testcase


  defp remove_client_short_name(%{ client: :unknown } = testcase), do: testcase
  defp remove_client_short_name(testcase) do
    %{ testcase | client: Map.delete(testcase.client, :short_name) }
  end


  defp remove_os_short_name(%{ os: :unknown } = testcase), do: testcase
  defp remove_os_short_name(testcase) do
    %{ testcase | os: Map.delete(testcase.os, :short_name) }
  end


  def unshorten_device_brand(%{ device: %{ brand: brand }} = testcase) do
    put_in(testcase,[ :device, :brand ], ShortCode.device_brand(brand, :long))
  end
  def unshorten_device_brand(testcase), do: testcase
end
