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
