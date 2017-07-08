defmodule UAInspector.Util do
  @moduledoc """
  Utility methods.
  """

  @doc """
  Upgrades a database regex into a detection regex.

  This prevents matching a string with other characters
  before the matching part.
  """
  @spec build_regex(regex :: String.t) :: Regex.t
  def build_regex(regex) do
    "(?:^|[^A-Z0-9\-_]|[^A-Z0-9\-]_|sprd-)(?:" <> regex <> ")"
    |> Regex.compile!([ :caseless ])
  end

  @doc """
  Replaces an empty string with `:unknown`.
  """
  @spec maybe_unknown(data :: String.t) :: :unknown | String.t
  def maybe_unknown("Unknown"), do: :unknown
  def maybe_unknown(""),        do: :unknown
  def maybe_unknown(data),      do: data

  @doc """
  Sanitizes a model string.
  """
  @spec sanitize_model(model :: String.t) :: String.t
  def sanitize_model(""),      do: ""
  def sanitize_model("Build"), do: ""
  def sanitize_model(model)    do
    model
    |> String.replace(~r/\$(\d)/, "")
    |> String.replace("_", " ")
    |> String.replace(~r/ TD$/, "")
    |> __MODULE__.trim()
  end

  @doc """
  Sanitizes a name string.
  """
  @spec sanitize_name(name :: String.t) :: String.t
  def sanitize_name(""),   do: ""
  def sanitize_name(name), do: __MODULE__.trim(name)

  @doc """
  Sanitizes a version string.
  """
  @spec sanitize_version(version :: String.t) :: String.t
  def sanitize_version(""),     do: ""
  def sanitize_version(version) do
    version
    |> String.replace(~r/\$(\d)/, "")
    |> String.replace(~r/\.$/, "")
    |> String.replace("_", ".")
    |> __MODULE__.trim()
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
  @spec to_semver(version :: String.t) :: String.t
  def to_semver(""),     do: ""
  def to_semver(version) do
    case String.split(version, ".", parts: 3) do
      [ maj ]         -> [ maj, "0" ] |> to_semver_string()
      [ maj, min ]    -> [ maj, min ] |> to_semver_string()
      [ maj, min, _ ] -> [ maj, min ] |> to_semver_string()
    end
  end

  defp to_semver_string([ maj, min ]) do
    case { Integer.parse(maj), Integer.parse(min) } do
      { :error,    _ }         -> "0.0.0"
      {{ maj, _ }, :error }    -> "#{ maj }.0.0"
      {{ maj, _ }, { min, _ }} -> "#{ maj }.#{ min }.0"
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


  # compatibility hack for elixir 1.2.x
  if Version.match?(System.version, "~> 1.2.0") do
    def to_charlist(string), do: String.to_char_list(string)
  else
    @doc false
    def to_charlist(string), do: String.to_charlist(string)
  end

  # compatibility hack for elixir 1.2.x
  if Version.match?(System.version, "~> 1.2.0") do
    @doc false
    def trim(string), do: String.strip(string)
  else
    @doc false
    def trim(string), do: String.trim(string)
  end
end
