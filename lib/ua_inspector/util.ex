defmodule UAInspector.Util do
  @moduledoc false

  @doc """
  Replaces an empty string with `:unknown`.
  """
  @spec maybe_unknown(data :: nil | String.t()) :: :unknown | String.t()
  def maybe_unknown(nil), do: :unknown
  def maybe_unknown(""), do: :unknown
  def maybe_unknown("Unknown"), do: :unknown
  def maybe_unknown(data), do: data
end
