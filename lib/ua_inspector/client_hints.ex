defmodule UAInspector.ClientHints do
  @moduledoc """
  Parse and store client hint headers for usage in device detection.
  """

  @type t :: %__MODULE__{
          application: String.t() | :unknown,
          architecture: String.t() | :unknown,
          bitness: String.t() | :unknown,
          form_factors: [String.t()],
          full_version: String.t() | :unknown,
          full_version_list: [{String.t(), String.t()}],
          mobile: boolean,
          model: String.t() | :unknown,
          platform: String.t() | :unknown,
          platform_version: String.t() | :unknown
        }

  defstruct application: :unknown,
            architecture: :unknown,
            bitness: :unknown,
            form_factors: [],
            full_version: :unknown,
            full_version_list: [],
            mobile: false,
            model: :unknown,
            platform: :unknown,
            platform_version: :unknown

  @doc """
  Parse headers into a new client hint struct.

  All headers are expected in dash-case (lowercase with dashes) format.

  Last header (if multiple possible) will be used for the result.
  """
  @spec new([{String.t(), String.t()}]) :: t()
  def new([]), do: %__MODULE__{}

  def new(headers) do
    Enum.reduce(headers, %__MODULE__{}, fn
      {"sec-ch-ua", _}, %{full_version_list: [_ | _]} = hints ->
        # ignore header if "sec-ch-ua-full-version-list" is already parsed
        hints

      {"sec-ch-ua", version_list}, hints ->
        %{hints | full_version_list: parse_version_list(version_list)}

      {"sec-ch-ua-arch", architecture}, hints ->
        %{hints | architecture: cleanup(architecture)}

      {"sec-ch-ua-bitness", bitness}, hints ->
        %{hints | bitness: cleanup(bitness)}

      {"sec-ch-ua-form-factors", form_factors_list}, hints ->
        %{hints | form_factors: parse_form_factors_list(form_factors_list)}

      {"sec-ch-ua-full-version", full_version}, hints ->
        %{hints | full_version: cleanup(full_version)}

      {"sec-ch-ua-full-version-list", version_list}, hints ->
        %{hints | full_version_list: parse_version_list(version_list)}

      {"sec-ch-ua-mobile", mobile}, hints ->
        %{hints | mobile: mobile == "?1"}

      {"sec-ch-ua-model", model}, hints ->
        %{hints | model: cleanup(model)}

      {"sec-ch-ua-platform", platform}, hints ->
        %{hints | platform: cleanup(platform)}

      {"sec-ch-ua-platform-version", platform_version}, hints ->
        %{hints | platform_version: cleanup(platform_version)}

      {"x-requested-with", application_header}, hints ->
        application =
          application_header
          |> cleanup()
          |> String.downcase()

        case application do
          "xmlhttprequest" -> hints
          _ -> %{hints | application: application}
        end

      _, hints ->
        hints
    end)
  end

  defp cleanup(value) do
    value
    |> String.trim()
    |> String.trim(~s("))
    |> String.trim()
  end

  defp parse_form_factors_list(form_factors_list) do
    form_factors_list
    |> String.split(",")
    |> Enum.map(fn raw ->
      raw
      |> String.trim()
      |> String.trim(~s("))
      |> String.downcase()
    end)
  end

  defp parse_version_list(version_list) do
    re_version = ~r/^"([^"]+)"; ?v="([^"]+)"(?:, )?/

    version_list
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Regex.run(re_version, &1, capture: :all_but_first))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn [brand, version] -> {brand, version} end)
  end
end
