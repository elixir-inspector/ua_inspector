defmodule UAInspector.Util.YAML do
  @moduledoc false

  @doc """
  Reads a yaml file and returns the contents.
  """
  @spec read_file(String.t()) :: any
  def read_file(path) do
    path
    |> String.to_charlist()
    |> :yamerl_constr.file([:str_node_as_binary])
    |> maybe_hd()
  end

  defp maybe_hd([]), do: []
  defp maybe_hd(data), do: hd(data)
end
