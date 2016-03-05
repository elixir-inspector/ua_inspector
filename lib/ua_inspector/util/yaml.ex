defmodule UAInspector.Util.YAML do
  @moduledoc """
  Convenience module for YAML file interactions.
  """

  @doc """
  Reads a yaml file and returns the contents.
  """
  @spec read_file(String.t) :: any
  def read_file(path) do
    path
    |> to_char_list()
    |> :yamerl_constr.file([ :str_node_as_binary ])
    |> hd()
  end
end
