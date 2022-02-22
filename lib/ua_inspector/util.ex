defmodule UAInspector.Util do
  @moduledoc false

  @doc """
  Generate a regex to be used for engine version detection.
  """
  @spec build_engine_regex(name :: String.t()) :: Regex.t()
  def build_engine_regex("Gecko") do
    # sigil_S used to ensure escaping is kept as-is
    # Concatenated expression:
    # - [ ](?:rv[: ]([0-9\.]+)).*Gecko\/[0-9]{8,10}
    # - Regular expression of `build_engine_regex("Gecko")`
    Regex.compile!(
      ~S"(?:[ ](?:rv[: ]([0-9\.]+)).*Gecko\/[0-9]{8,10}|Gecko\s*\/?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$)))))",
      [:caseless]
    )
  end

  def build_engine_regex(name) do
    Regex.compile!(name <> ~S"\s*\/?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$))))", [:caseless])
  end

  @doc """
  Upgrades a database regex into a detection regex.

  This prevents matching a string with other characters
  before the matching part.
  """
  @spec build_regex(regex :: String.t()) :: Regex.t()
  def build_regex(regex) do
    Regex.compile!("(?:^|[^A-Z0-9\-_]|[^A-Z0-9\-]_|sprd-|MZ-)(?:" <> regex <> ")", [:caseless])
  end

  @doc """
  Replaces an empty string with `:unknown`.
  """
  @spec maybe_unknown(data :: String.t()) :: :unknown | String.t()
  def maybe_unknown(""), do: :unknown
  def maybe_unknown("Unknown"), do: :unknown
  def maybe_unknown(data), do: data

  @doc """
  Sanitizes a version string.
  """
  @spec sanitize_version(version :: String.t()) :: String.t()
  def sanitize_version(""), do: ""

  def sanitize_version(version) do
    version
    |> String.replace(~r/\$(\d)/, "")
    |> String.replace(~r/\.$/, "")
    |> String.replace("_", ".")
    |> String.trim()
  end

  @doc """
  Converts an unknown version string to a semver-comparable format.

  Everything except the `major` and `minor` version is dropped as
  these two parts are the only available/needed.

  Missing values are filled with zeroes while empty strings are ignored.

  If a non-integer value is found it is ignored and every part
  including and after it will be a zero.

  ## Examples

      iex> to_semver("15")
      "15.0.0"

      iex> to_semver("3.6")
      "3.6.0"

      iex> to_semver("8.8.8")
      "8.8.0"

      iex> to_semver("")
      ""

      iex> to_semver("invalid")
      "0.0.0"

      iex> to_semver("3.help")
      "3.0.0"

      iex> to_semver("0.1.invalid")
      "0.1.0"
  """
  @spec to_semver(version :: String.t()) :: String.t()
  def to_semver(""), do: ""

  def to_semver(version) do
    case String.split(version, ".", parts: 3) do
      [maj] -> to_semver_string(maj, "0")
      [maj, min] -> to_semver_string(maj, min)
      [maj, min, _] -> to_semver_string(maj, min)
    end
  end

  defp to_semver_string(major, minor) do
    case {Integer.parse(major), Integer.parse(minor)} do
      {:error, _} -> "0.0.0"
      {{maj, _}, :error} -> "#{maj}.0.0"
      {{maj, _}, {min, _}} -> "#{maj}.#{min}.0"
    end
  end

  @doc """
  Replaces PHP-Style regex captures with their values.
  """
  @spec uncapture(data :: String.t(), captures :: list) :: String.t()
  def uncapture(data, captures), do: uncapture(data, captures, 1)

  defp uncapture(data, [], _), do: data

  defp uncapture(data, [capture | captures], index) do
    data
    |> String.replace("\$#{index}", capture)
    |> uncapture(captures, index + 1)
  end
end
