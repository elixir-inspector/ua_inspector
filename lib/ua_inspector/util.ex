defmodule UAInspector.Util do
  @moduledoc false

  @doc """
  Generate a regex to be used for engine version detection.
  """
  @spec build_engine_regex(name :: String.t()) :: Regex.t()
  def build_engine_regex("Clecko") do
    # sigil_S used to ensure escaping is kept as-is
    # Concatenated expression:
    # - [ ](?:rv[: ]([0-9\.]+)).*(?:g|cl)ecko\/[0-9]{8,10}
    # - Regular expression of `build_engine_regex("Clecko")`
    Regex.compile!(
      ~S"(?:[ ](?:rv[: ]([0-9\.]+)).*(?:g|cl)ecko\/[0-9]{8,10}|Gecko\s*\/?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$)))))",
      [:caseless]
    )
  end

  def build_engine_regex("Gecko") do
    # sigil_S used to ensure escaping is kept as-is
    # Concatenated expression:
    # - [ ](?:rv[: ]([0-9\.]+)).*(?:g|cl)ecko\/[0-9]{8,10}
    # - Regular expression of `build_engine_regex("Gecko")`
    Regex.compile!(
      ~S"(?:[ ](?:rv[: ]([0-9\.]+)).*(?:g|cl)ecko\/[0-9]{8,10}|Gecko\s*\/?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$)))))",
      [:caseless]
    )
  end

  def build_engine_regex("Arachne"), do: build_engine_regex("Arachne\\/5\\.")
  def build_engine_regex("Blink"), do: build_engine_regex("Chrome|Cronet")
  def build_engine_regex("LibWeb"), do: build_engine_regex("LibWeb\\+LibJs")

  def build_engine_regex(name) do
    Regex.compile!("(?:" <> name <> ~S")\s*\/?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$))))", [
      :caseless
    ])
  end

  @doc """
  Upgrades a database regex into a detection regex.

  This prevents matching a string with other characters
  before the matching part.
  """
  @spec build_regex(regex :: String.t()) :: Regex.t()
  def build_regex(regex) do
    Regex.compile!("(?:^|[^A-Z0-9_-]|[^A-Z0-9-]_|sprd-|MZ-)(?:" <> regex <> ")", [:caseless])
  end

  @doc """
  Build a generic matching regex.
  """
  @spec build_base_regex(regex :: String.t()) :: Regex.t()
  def build_base_regex(regex) do
    Regex.compile!("(?:^|[^A-Z_-])(?:" <> regex <> ")", [:caseless])
  end

  @doc """
  Replaces an empty string with `:unknown`.
  """
  @spec maybe_unknown(data :: nil | String.t()) :: :unknown | String.t()
  def maybe_unknown(nil), do: :unknown
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
      "8.8.8"

      iex> to_semver("")
      ""

      iex> to_semver("invalid")
      "0.0.0"

      iex> to_semver("3.help")
      "3.0.0"

      iex> to_semver("0.1.invalid")
      "0.1.0"

      iex> to_semver("1.2.3.4")
      "1.2.3"
  """
  @spec to_semver(version :: String.t(), parts :: integer) :: String.t()
  def to_semver(version, parts \\ 3)
  def to_semver("", _), do: ""

  def to_semver(version, parts) do
    case String.split(version, ".", parts: parts) do
      [maj] -> to_semver_string(maj, "0", "0", nil)
      [maj, min] -> to_semver_string(maj, min, "0", nil)
      [maj, min, patch] -> to_semver_string(maj, min, patch, nil)
      [maj, min, patch, pre] -> to_semver_string(maj, min, patch, pre)
    end
  end

  @doc """
  Forces a "pre-release" setting to a semver-comparable version.

  ## Examples

      iex> to_semver_with_pre("15")
      "15.0.0-0"

      iex> to_semver_with_pre("1.2.3.4")
      "1.2.3-4"

      iex> to_semver("")
      ""
  """
  def to_semver_with_pre(version) do
    semver = to_semver(version, 4)

    cond do
      "" == semver -> semver
      String.contains?(semver, "-") -> semver
      true -> semver <> "-0"
    end
  end

  defp to_semver_string(major, minor, patch, pre) do
    version =
      case {Integer.parse(major), Integer.parse(minor), Integer.parse(patch)} do
        {:error, _, _} -> "0.0.0"
        {{maj, _}, :error, _} -> "#{maj}.0.0"
        {{maj, _}, {min, _}, :error} -> "#{maj}.#{min}.0"
        {{maj, _}, {min, _}, {patch, _}} -> "#{maj}.#{min}.#{patch}"
      end

    if nil != pre do
      version <> "-" <> pre
    else
      version
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
