defmodule Mix.UAInspector.Verify.Cleanup do
  @moduledoc """
  Cleans up testcases.
  """

  alias UAInspector.ShortCodeMap.DeviceBrands

  @empty_to_quotes [
    [ :bot, :category ],
    [ :bot, :producer, :name ],
    [ :bot, :producer, :url ],
    [ :bot, :url ]
  ]

  @empty_to_unknown [
    [ :client ],
    [ :client, :engine ],
    [ :client, :engine_version ],
    [ :client, :version ],
    [ :device, :brand ],
    [ :device, :model ],
    [ :device, :type ],
    [ :os, :platform ],
    [ :os, :version ]
  ]


  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> convert_empty(@empty_to_quotes,  "")
    |> convert_empty(@empty_to_unknown, :unknown)
    |> cleanup_client_engine()
    |> cleanup_client_engine_version()
    |> cleanup_client_version()
    |> cleanup_device_model()
    |> cleanup_os_entry()
    |> cleanup_os_version()
    |> remove_client_short_name()
    |> remove_os_short_name()
    |> remove_unknown_device()
    |> unshorten_device_brand()
  end


  defp convert_empty(testcase, [], _), do: testcase
  defp convert_empty(testcase, [ path | paths ], replacement) do
    case get_in(testcase, path) do
      :null-> put_in(testcase, path, replacement)
      ""   -> put_in(testcase, path, replacement)
      _    -> testcase
    end
    |> convert_empty(paths, replacement)
  rescue
    FunctionClauseError -> convert_empty(testcase, paths, replacement)
  end


  defp cleanup_client_engine(%{ client: client } = testcase) when is_map(client) do
    client = case Map.has_key?(client, :engine) do
      true  -> client
      false -> Map.put(client, :engine, :unknown)
    end

    %{ testcase | client: client }
  end
  defp cleanup_client_engine(testcase), do: testcase


  defp cleanup_client_engine_version(%{ client: %{ engine_version: version }} = testcase) when is_number(version) do
    put_in(testcase, [ :client, :engine_version ], to_string(version))
  end
  defp cleanup_client_engine_version(%{ client: client } = testcase) when is_map(client) do
    client = case Map.has_key?(client, :engine_version) do
      true  -> client
      false -> Map.put(client, :engine_version, :unknown)
    end

    %{ testcase | client: client }
  end
  defp cleanup_client_engine_version(testcase), do: testcase


  defp cleanup_client_version(%{ client: %{ version: version }} = testcase) when is_number(version) do
    put_in(testcase, [ :client, :version ], to_string(version))
  end
  defp cleanup_client_version(testcase), do: testcase


  defp cleanup_device_model(%{ device: %{ model: model }} = testcase) when is_number(model) do
    put_in(testcase, [ :device, :model ], to_string(model))
  end
  defp cleanup_device_model(testcase), do: testcase


  defp cleanup_os_entry(%{ os: os } = testcase) do
    os = case Map.keys(os) do
      [] -> :unknown
      _  -> os
    end

    %{ testcase | os: os }
  end
  defp cleanup_os_entry(testcase), do: testcase


  defp cleanup_os_version(%{ os: %{ version: version }} = testcase) when is_number(version) do
    put_in(testcase, [ :os, :version ], to_string(version))
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
