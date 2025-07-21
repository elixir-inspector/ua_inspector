defmodule UAInspector.Util.Regex do
  @moduledoc false

  @doc """
  Generate a regex to be used for engine version detection.
  """
  @spec build_engine_regex(name :: String.t()) :: Regex.t()
  def build_engine_regex("Clecko") do
    # sigil_S used to ensure escaping is kept as-is
    # Concatenated expression:
    # - [ ](?:rv[: ]([0-9.]+)).*(?:g|cl)ecko\/[0-9]{8,10}
    # - Regular expression of `build_engine_regex("Clecko")`
    Regex.compile!(
      ~S"(?:[ ](?:rv[: ]([0-9.]+)).*(?:g|cl)ecko\/[0-9]{8,10}|Clecko\s*[/_]?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$)))))",
      [:caseless]
    )
  end

  def build_engine_regex("Gecko") do
    # sigil_S used to ensure escaping is kept as-is
    # Concatenated expression:
    # - [ ](?:rv[: ]([0-9.]+)).*(?:g|cl)ecko\/[0-9]{8,10}
    # - Regular expression of `build_engine_regex("Gecko")`
    Regex.compile!(
      ~S"(?:[ ](?:rv[: ]([0-9.]+)).*(?:g|cl)ecko\/[0-9]{8,10}|Gecko\s*[/_]?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$)))))",
      [:caseless]
    )
  end

  def build_engine_regex("Arachne"), do: build_engine_regex("Arachne\\/5\\.")
  def build_engine_regex("Blink"), do: build_engine_regex("Chr[o0]me|Chromium|Cronet")
  def build_engine_regex("LibWeb"), do: build_engine_regex("LibWeb\\+LibJs")

  def build_engine_regex(name) do
    Regex.compile!(
      "(?:" <> name <> ~S")\s*[/_]?\s*((?(?=\d+\.\d)\d+[.\d]*|\d{1,7}(?=(?:\D|$))))",
      [:caseless]
    )
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
