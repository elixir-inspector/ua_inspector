defmodule UAInspector.Util.YAML do
  @moduledoc false

  alias UAInspector.Config

  @doc """
  Reads a yaml file and returns the contents.
  """
  @spec read_file(Path.t()) :: {:ok, term} | {:error, File.posix()}
  def read_file(file) do
    case File.stat(file) do
      {:ok, _} ->
        {reader_mod, reader_fun, reader_extra_args} = Config.yaml_file_reader()

        reader_mod
        |> apply(reader_fun, [file | reader_extra_args])
        |> maybe_hd()

      error ->
        error
    end
  end

  defp maybe_hd([]), do: {:ok, []}
  defp maybe_hd([data | _]), do: {:ok, data}
end
