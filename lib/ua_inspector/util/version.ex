defmodule UAInspector.Util.Version do
  @moduledoc false

  @doc """
  Sanitizes a version string.
  """
  @spec sanitize(version :: String.t()) :: String.t()
  def sanitize(""), do: ""

  def sanitize(version) do
    version
    |> String.replace(~r/\$(\d)/, "")
    |> String.replace(~r/\.$/, "")
    |> String.replace("_", ".")
    |> String.trim()
  end

  @doc """
  Converts an unknown version string to a semver-comparable format.

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

      iex> to_semver("1.2.3.4", 4)
      "1.2.3-4"
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

      iex> to_semver_with_pre("")
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
end
