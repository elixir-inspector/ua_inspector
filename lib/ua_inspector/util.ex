defmodule UAInspector.Util do
  @moduledoc """
  Utility methods.
  """

  @doc """
  Replaces an empty string with `:unknown`.
  """
  @spec maybe_unknown(data :: String.t) :: :unknown | String.t
  def maybe_unknown(""),   do: :unknown
  def maybe_unknown(data), do: data

  @doc """
  Sanitizes a model string.
  """
  @spec sanitize_model(model :: String.t) :: String.t
  def sanitize_model(""),   do: ""
  def sanitize_model(model) do
    model
    |> String.replace(~r/\$(\d)/, "")
    |> String.strip()
  end

  @doc """
  Sanitizes a version string.
  """
  @spec sanitize_version(version :: String.t) :: String.t
  def sanitize_version(""),     do: ""
  def sanitize_version(version) do
    version
    |> String.replace(~r/\$(\d)/, "")
    |> String.strip()
  end

  @doc """
  Converts an unknown version string to a semver-comparable format.

  Everything except the `major` and `minor` version is dropped as
  these two parts are the only available/needed.

  Missing values are filled with zeroes while empty strings are ignored.

  ## Examples

      iex> to_semver("15")
      "15.0.0"

      iex> to_semver("3.6")
      "3.6.0"

      iex> to_semver("8.8.8")
      "8.8.0"

      iex> to_semver("")
      ""
  """
  @spec to_semver(version :: String.t) :: String.t
  def to_semver(""),     do: ""
  def to_semver(version) do
    case String.split(version, ".", parts: 3) do
      [ maj ]         -> [ maj, "0", "0" ] |> Enum.join(".")
      [ maj, min ]    -> [ maj, min, "0" ] |> Enum.join(".")
      [ maj, min, _ ] -> [ maj, min, "0" ] |> Enum.join(".")
    end
  end

  @doc """
  Replaces PHP-Style regex captures with their values.
  """
  @spec uncapture(data :: String.t, captures :: list) :: String.t
  def uncapture(data, captures), do: uncapture(data, captures, 0)


  defp uncapture(data, [],                     _),    do: data
  defp uncapture(data, [ capture | captures ], index) do
    data
    |> String.replace("\$#{ index }", capture)
    |> uncapture(captures, index + 1)
  end
end
