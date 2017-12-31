defmodule UAInspector.Downloader.ShortCodeMapConverter do
  @moduledoc """
  Utility module to extract short code maps from php sources into yaml files.
  """

  @doc """
  Extracts the map defined with variable name `var` from the file `file`.

  Returns the complete list of all mapping tuples.
  """
  @spec extract(String.t(), :hash | :list, String.t()) :: list
  def extract(var, type, file) do
    re_opts = [:dotall, {:newline, :anycrlf}, :multiline, :ungreedy]
    source = File.read!(file)

    "\\$#{var} = array\\((?<map>.*)\\);"
    |> Regex.compile!(re_opts)
    |> Regex.named_captures(source)
    |> Map.get("map", "")
    |> parse_source(type)
  end

  @doc """
  Writes yaml file for a list of short code mappings.
  """
  @spec write_yaml(list, :hash | :list, String.t()) :: :ok
  def write_yaml(map, :hash, file) do
    {:ok, _} =
      File.open(file, [:write], fn outfile ->
        for {short, long} <- map do
          outfile |> IO.write("- \"#{short}\": \"#{long}\"\n")
        end
      end)

    :ok
  end

  def write_yaml(map, :list, file) do
    {:ok, _} =
      File.open(file, [:write], fn outfile ->
        for item <- map do
          outfile |> IO.write("- \"#{item}\"\n")
        end
      end)

    :ok
  end

  defp mapping_to_entry(nil), do: nil
  defp mapping_to_entry([_, item]), do: item
  defp mapping_to_entry([_, short, long]), do: {short, long}

  defp parse_mapping(mapping, :hash) do
    "'(.+)' => '(.+)'"
    |> Regex.compile!()
    |> Regex.run(mapping)
    |> mapping_to_entry()
  end

  defp parse_mapping(mapping, :list) do
    "'(.+)'"
    |> Regex.compile!([:ungreedy])
    |> Regex.run(mapping)
    |> mapping_to_entry()
  end

  defp parse_source(source, :hash) do
    source
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_mapping(&1, :hash))
  end

  defp parse_source(source, :list) do
    source
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&parse_mapping(&1, :list))
  end
end
