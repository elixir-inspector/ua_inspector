defmodule Mix.UAInspector.Verify.Cleanup do
  @moduledoc """
  Cleans up testcases.
  """

  alias UAInspector.ShortCodeMap.DeviceBrands

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> cleanup_bot_category()
    |> cleanup_bot_url()
    |> cleanup_bot_producer_name()
    |> cleanup_bot_producer_url()
    |> cleanup_client_engine()
    |> cleanup_client_version()
    |> cleanup_device_brand()
    |> cleanup_device_model()
    |> cleanup_device_type()
    |> cleanup_os_entry()
    |> cleanup_os_platform()
    |> cleanup_os_version()
    |> remove_client_short_name()
    |> remove_os_short_name()
    |> remove_unknown_device()
    |> unshorten_device_brand()
  end


  defp cleanup_bot_category(%{ bot: %{ category: :null }} = testcase) do
    put_in(testcase, [ :bot, :category ], "")
  end
  defp cleanup_bot_category(testcase), do: testcase

  defp cleanup_bot_url(%{ bot: %{ url: :null }} = testcase) do
    put_in(testcase, [ :bot, :url ], "")
  end
  defp cleanup_bot_url(testcase), do: testcase

  defp cleanup_bot_producer_name(%{ bot: %{ producer: %{ name: :null }}} = testcase) do
    put_in(testcase, [ :bot, :producer, :name ], "")
  end
  defp cleanup_bot_producer_name(testcase), do: testcase

  defp cleanup_bot_producer_url(%{ bot: %{ producer: %{ url: :null }}} = testcase) do
    put_in(testcase, [ :bot, :producer, :url ], "")
  end
  defp cleanup_bot_producer_url(testcase), do: testcase

  defp cleanup_client_engine(%{ client: %{ engine: :null }} = testcase) do
    put_in(testcase, [ :client, :engine ], :unknown)
  end
  defp cleanup_client_engine(%{ client: :null } = testcase) do
    %{ testcase | client: :unknown }
  end
  defp cleanup_client_engine(%{ client: client } = testcase) do
    client = case Map.has_key?(client, :engine) do
      true  -> client
      false -> Map.put(client, :engine, :unknown)
    end

    %{ testcase | client: client }
  end
  defp cleanup_client_engine(testcase), do: testcase


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
  defp cleanup_device_model(%{ device: %{ model: model }} = testcase) do
    put_in(testcase, [ :device, :model ], to_string(model))
  end
  defp cleanup_device_model(testcase), do: testcase


  defp cleanup_device_type(%{ device: %{ type: :null }} = testcase) do
    put_in(testcase, [ :device, :type ], :unknown)
  end
  defp cleanup_device_type(testcase), do: testcase


  defp cleanup_os_entry(%{ os: os } = testcase) do
    os = case Map.keys(os) do
      [] -> :unknown
      _  -> os
    end

    %{ testcase | os: os }
  end
  defp cleanup_os_entry(testcase), do: testcase


  defp cleanup_os_platform(%{ os: %{ platform: :null }} = testcase) do
    put_in(testcase, [ :os, :platform ], :unknown)
  end
  defp cleanup_os_platform(testcase), do: testcase


  defp cleanup_os_version(%{ os: %{ version: :null }} = testcase) do
    put_in(testcase, [ :os, :version ], :unknown)
  end
  defp cleanup_os_version(testcase), do: testcase


  defp remove_client_short_name(%{ client: :unknown } = testcase), do: testcase
  defp remove_client_short_name(%{ client: _ } = testcase) do
    %{ testcase | client: Map.delete(testcase.client, :short_name) }
  end
  defp remove_client_short_name(testcase), do: testcase


  defp remove_os_short_name(%{ os: :unknown } = testcase), do: testcase
  defp remove_os_short_name(%{ os: _ } = testcase) do
    %{ testcase | os: Map.delete(testcase.os, :short_name) }
  end
  defp remove_os_short_name(testcase), do: testcase


  defp remove_unknown_device(%{ device: %{ type:  :unknown,
                                           brand: :unknown,
                                           model: :unknown }} = result) do
    %{ result | device: :unknown }
  end

  defp remove_unknown_device(result), do: result


  def unshorten_device_brand(%{ device: %{ brand: brand }} = testcase) do
    put_in(testcase,[ :device, :brand ], DeviceBrands.to_long(brand))
  end
  def unshorten_device_brand(testcase), do: testcase
end
