defmodule UAInspectorVerify.Cleanup.Base do
  @moduledoc false

  def empty_to_unknown(testcase, []), do: testcase

  def empty_to_unknown(testcase, [path | paths]) do
    testcase
    |> get_in(path)
    |> case do
      :null -> put_in(testcase, path, :unknown)
      "" -> put_in(testcase, path, :unknown)
      _ -> testcase
    end
    |> empty_to_unknown(paths)
  rescue
    FunctionClauseError -> empty_to_unknown(testcase, paths)
  end

  def prepare_headers(%{headers: headers} = testcase),
    do: %{testcase | headers: Map.new(headers, &prepare_header/1)}

  def prepare_headers(testcase), do: testcase

  def version_to_string(testcase, []), do: testcase

  def version_to_string(testcase, [path | paths]) do
    testcase
    |> get_in(path)
    |> case do
      version when is_number(version) -> put_in(testcase, path, to_string(version))
      _ -> testcase
    end
    |> version_to_string(paths)
  rescue
    FunctionClauseError -> version_to_string(testcase, paths)
  end

  defp prepare_header({key, value}) do
    header =
      key
      |> Atom.to_string()
      |> String.downcase()
      |> prepare_header_strip_http()
      |> prepare_header_prepend_sec_ua()
      |> prepare_header_fixup()

    value = prepare_header_value(value)

    {header, value}
  end

  defp prepare_header_fixup("sec-ch-ua-architecture"), do: "sec-ch-ua-arch"
  defp prepare_header_fixup("sec-ch-ua-fullversionlist"), do: "sec-ch-ua-full-version-list"
  defp prepare_header_fixup("sec-ch-ua-uafullversion"), do: "sec-ch-ua-full-version"
  defp prepare_header_fixup("sec-ch-ua-platformversion"), do: "sec-ch-ua-platform-version"
  defp prepare_header_fixup(header), do: header

  defp prepare_header_prepend_sec_ua("sec-ch-ua" = header), do: header
  defp prepare_header_prepend_sec_ua("x-requested-with" = header), do: header
  defp prepare_header_prepend_sec_ua("sec-ch-ua-" <> _ = header), do: header
  defp prepare_header_prepend_sec_ua(header), do: "sec-ch-ua-" <> header

  defp prepare_header_strip_http("http-" <> header), do: header
  defp prepare_header_strip_http(header), do: header

  defp prepare_header_value([[{"brand", _}, {"version", _}] | _] = values) do
    Enum.map_join(
      values,
      ", ",
      fn [{"brand", brand}, {"version", version}] -> ~s("#{brand}";v="#{version}") end
    )
  end

  defp prepare_header_value([_ | _]), do: ""
  defp prepare_header_value(:null), do: ""
  defp prepare_header_value(value), do: value
end
