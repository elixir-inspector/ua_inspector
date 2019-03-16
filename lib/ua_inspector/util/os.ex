defmodule UAInspector.Util.OS do
  @moduledoc false

  alias UAInspector.ShortCodeMap

  @doc """
  Checks whether an operating system is treated as "desktop only".
  """
  @spec desktop_only?(os :: map | :unknown) :: boolean
  def desktop_only?(%{name: name}) do
    short_code = ShortCodeMap.OSs.to_short(name)

    case family(short_code) do
      nil ->
        false

      family ->
        ShortCodeMap.DesktopFamilies.list()
        |> Enum.any?(&(&1 == {family}))
    end
  end

  def desktop_only?(_), do: false

  @doc """
  Returns the OS family for an OS short code.

  Unknown short codes return `nil` as their family.
  """
  @spec family(short_code :: String.t()) :: String.t() | nil
  def family(short_code) do
    lookup =
      ShortCodeMap.OSFamilies.list()
      |> Enum.find(&in_family?(short_code, &1))

    case lookup do
      {name, _} -> name
      _ -> nil
    end
  end

  @doc """
  Returns the proper case version of a downcase os name.

  Unknown names are returned unmodified.

  ## Examples

      iex> proper_case("debian")
      "Debian"

      iex> proper_case("--UnKnOnWn--")
      "--UnKnOnWn--"
  """
  @spec proper_case(os :: String.t()) :: String.t()
  def proper_case(os) do
    ShortCodeMap.OSs.list()
    |> Enum.find({os, os}, fn {_, o} ->
      String.downcase(os) == String.downcase(o)
    end)
    |> elem(1)
  end

  # Internal methods

  defp in_family?(short_code, {_, short_codes}) do
    Enum.any?(short_codes, &(&1 == short_code))
  end
end
