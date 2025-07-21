defmodule UAInspector.Downloader.ShortCodeMapConverter do
  @moduledoc false

  @doc """
  Extracts the map defined with variable name `var` from the file `file`.

  Returns the complete list of all mapping tuples.
  """
  @spec extract(String.t(), :hash | :hash_with_list | :list, String.t()) :: list
  def extract(var, type, file) do
    re_opts = [:dotall, {:newline, :anycrlf}, :multiline, :ungreedy]
    source = File.read!(file)

    "\\$#{var} = (?:array\\(|\\[)(?<map>.*)(?:\\)|\\]);"
    |> Regex.compile!(re_opts)
    |> Regex.named_captures(source)
    |> Kernel.||(%{})
    |> Map.get("map", "")
    |> parse_source(type)
  end

  @doc """
  Writes yaml file for a list of short code mappings.
  """
  @spec write_yaml(list, :hash | :hash_with_list | :list, String.t()) :: :ok
  def write_yaml(map, :hash, file) do
    {:ok, _} =
      File.open(file, [:write, :utf8], fn outfile ->
        for {short, long} <- map do
          IO.write(
            outfile,
            [~s(- "), short, ~s(": "), long, ~s("\n)]
          )
        end
      end)

    :ok
  end

  def write_yaml(map, :hash_with_list, file) do
    {:ok, _} =
      File.open(file, [:write, :utf8], fn outfile ->
        for {entry, elements} <- map do
          elements_content = Enum.map(elements, &[~s(  - "), &1, ~s("\n)])

          IO.write(
            outfile,
            [~s(- "), entry, ~s(":\n), elements_content]
          )
        end
      end)

    :ok
  end

  def write_yaml(map, :list, file) do
    {:ok, _} =
      File.open(file, [:write, :utf8], fn outfile ->
        for item <- map do
          IO.write(outfile, [~s(- "), item, ~s("\n)])
        end
      end)

    :ok
  end

  defp mapping_to_entry(nil), do: nil
  defp mapping_to_entry([_, item]), do: item
  defp mapping_to_entry([_, short, long]), do: {short, long}

  defp mapping_to_entry_list(nil), do: nil

  defp mapping_to_entry_list({entry, elements}) do
    {
      entry,
      elements
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.trim(&1, "'"))
    }
  end

  defp parse_mapping(mapping, :hash) do
    ~r/'(.+)' +=> +'(.+)'/
    |> Regex.run(mapping)
    |> mapping_to_entry()
  end

  defp parse_mapping(mapping, :hash_with_list) do
    ~r/'(.+)' +=> +(?:array\(|\[)(.+)(?:\)|\]|$)/sU
    |> Regex.run(mapping)
    |> mapping_to_entry()
    |> mapping_to_entry_list()
  end

  defp parse_mapping(mapping, :list) do
    ~r/'(.+)'/U
    |> Regex.run(mapping)
    |> mapping_to_entry()
  end

  defp parse_source(source, :hash) do
    source
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_mapping(&1, :hash))
  end

  defp parse_source(source, :hash_with_list) do
    source
    |> String.trim()
    |> String.split(~r/[)\]],/)
    |> Enum.map(&parse_mapping(&1, :hash_with_list))
    |> Enum.reject(&is_nil/1)
  end

  defp parse_source(source, :list) do
    source
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse_mapping(&1, :list))
    |> Enum.reject(&is_nil/1)
  end
end
