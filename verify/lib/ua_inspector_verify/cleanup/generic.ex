defmodule UAInspectorVerify.Cleanup.Generic do
  @moduledoc """
  Cleans up testcases.
  """

  alias UAInspectorVerify.Cleanup.Base

  @empty_to_unknown [
    [:client],
    [:client, :engine],
    [:client, :engine_version],
    [:client, :version],
    [:device, :brand],
    [:device, :model],
    [:device, :type],
    [:os, :platform],
    [:os, :version]
  ]

  @unknown_to_atom [
    [:browser_family],
    [:os_family]
  ]

  @doc """
  Cleans up a test case.
  """
  @spec cleanup(testcase :: map) :: map
  def cleanup(testcase) do
    testcase
    |> Base.empty_to_unknown(@empty_to_unknown)
    |> Base.prepare_headers()
    |> convert_unknown(@unknown_to_atom)
    |> cleanup_bot_producers()
    |> cleanup_client_engine()
    |> cleanup_client_engine_version()
    |> cleanup_os_entry()
    |> remove_unknown_device()
  end

  defp convert_unknown(testcase, []), do: testcase

  defp convert_unknown(testcase, [path | paths]) do
    testcase
    |> get_in(path)
    |> case do
      "Unknown" -> put_in(testcase, path, :unknown)
      _ -> testcase
    end
    |> convert_unknown(paths)
  end

  defp cleanup_bot_producers(%{bot: %{producer: %{name: name, url: url}} = bot} = testcase) do
    name = if name === :null, do: "", else: name
    url = if url === :null, do: "", else: url

    %{testcase | bot: %{bot | producer: %{name: name, url: url}}}
  end

  defp cleanup_bot_producers(%{bot: %{producer: %{name: name}} = bot} = testcase) do
    name = if name === :null, do: "", else: name

    %{testcase | bot: %{bot | producer: %{name: name, url: :unknown}}}
  end

  defp cleanup_bot_producers(testcase), do: testcase

  defp cleanup_client_engine(%{client: client} = testcase) when is_map(client) do
    client =
      if Map.has_key?(client, :engine) do
        client
      else
        Map.put(client, :engine, :unknown)
      end

    %{testcase | client: client}
  end

  defp cleanup_client_engine(testcase), do: testcase

  defp cleanup_client_engine_version(%{client: client} = testcase) when is_map(client) do
    client =
      if Map.has_key?(client, :engine_version) do
        client
      else
        Map.put(client, :engine_version, :unknown)
      end

    %{testcase | client: client}
  end

  defp cleanup_client_engine_version(testcase), do: testcase

  defp cleanup_os_entry(%{os: []} = testcase) do
    %{testcase | os: :unknown}
  end

  defp cleanup_os_entry(%{os: %{version: version} = os} = testcase) when is_integer(version) do
    %{testcase | os: %{os | version: Integer.to_string(version)}}
  end

  defp cleanup_os_entry(testcase), do: testcase

  defp remove_unknown_device(
         %{device: %{type: :unknown, brand: :unknown, model: :unknown}} = testcase
       ) do
    %{testcase | device: :unknown}
  end

  defp remove_unknown_device(testcase), do: testcase
end
