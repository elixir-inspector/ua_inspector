defmodule UAInspector.Util.YAML do
  @moduledoc false

  alias UAInspector.Config

  @doc """
  Reads a yaml file and returns the contents.
  """
  @spec read_file(Path.t()) :: {:ok, term} | {:error, :file_empty | File.posix()}
  def read_file(file) do
    {reader_mod, reader_fun, reader_extra_args} = Config.yaml_file_reader()

    with {:ok, _} <- File.stat(file),
         [data | _] <- apply(reader_mod, reader_fun, [file | reader_extra_args]) do
      {:ok, data}
    else
      [] -> {:error, :file_empty}
      {:error, _} = error -> error
    end
  end

  @doc """
  Converts YAML results to string while replacing `:null` with `nil`.
  """
  @spec maybe_to_string(any) :: binary | nil
  def maybe_to_string(nil), do: nil
  def maybe_to_string(:null), do: nil
  def maybe_to_string(data) when is_binary(data), do: data
  def maybe_to_string(data), do: to_string(data)
end
