defmodule UAInspector.Util.YAML do
  @moduledoc """
  Convenience module for YAML file interactions.
  """

  alias UAInspector.Util

  @doc """
  Reads a yaml file and returns the contents.
  """
  @spec read_file(String.t()) :: any
  def read_file(path) do
    path
    |> Util.to_charlist()
    |> :yamerl_constr.file([:str_node_as_binary])
    |> maybe_hd()
  end

  defp maybe_hd([]), do: []
  defp maybe_hd(data), do: hd(data)
end
