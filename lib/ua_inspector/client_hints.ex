defmodule UAInspector.ClientHints do
  @moduledoc false

  @type t :: %__MODULE__{
          architecture: String.t() | :unknown,
          bitness: String.t() | :unknown,
          full_version: String.t() | :unknown,
          full_version_list: [{String.t(), String.t()}],
          mobile: boolean,
          model: String.t() | :unknown,
          platform: String.t() | :unknown,
          platform_version: String.t() | :unknown
        }

  defstruct architecture: :unknown,
            bitness: :unknown,
            full_version: :unknown,
            full_version_list: [],
            mobile: false,
            model: :unknown,
            platform: :unknown,
            platform_version: :unknown

  @regex_version ~r/^"([^"]+)"; ?v="([^"]+)"(?:, )?/

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
        %{hints | architecture: String.trim(architecture, ~s("))}

      {"sec-ch-ua-bitness", bitness}, hints ->
        %{hints | bitness: String.trim(bitness, ~s("))}

      {"sec-ch-ua-full-version", full_version}, hints ->
        %{hints | full_version: String.trim(full_version, ~s("))}

      {"sec-ch-ua-full-version-list", version_list}, hints ->
        %{hints | full_version_list: parse_version_list(version_list)}

      {"sec-ch-ua-mobile", mobile}, hints ->
        %{hints | mobile: mobile == "?1"}

      {"sec-ch-ua-model", model}, hints ->
        %{hints | model: String.trim(model, ~s("))}

      {"sec-ch-ua-platform", platform}, hints ->
        %{hints | platform: String.trim(platform, ~s("))}

      {"sec-ch-ua-platform-version", platform_version}, hints ->
        %{hints | platform_version: String.trim(platform_version, ~s("))}

      _, hints ->
        hints
    end)
  end

  defp parse_version_list(version_list) do
    version_list
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&Regex.run(@regex_version, &1, capture: :all_but_first))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn [brand, version] -> {brand, version} end)
  end
end
