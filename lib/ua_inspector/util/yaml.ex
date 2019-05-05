defmodule UAInspector.Util.YAML do
  @moduledoc false

  alias UAInspector.Config

  @doc """
  Reads a yaml file and returns the contents.
  """
  @spec read_file(Path.t()) :: any
  def read_file(file) do
    {reader_mod, reader_fun, reader_extra_args} = Config.yaml_file_reader()

    reader_mod
    |> apply(reader_fun, [file | reader_extra_args])
    |> maybe_hd()
  end

  defp maybe_hd([]), do: []
  defp maybe_hd([data | _]), do: data
end
