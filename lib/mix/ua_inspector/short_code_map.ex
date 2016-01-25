defmodule Mix.UAInspector.ShortCodeMap do
  @moduledoc """
  Utility module to extract short code maps from source files.
  """

  @doc """
  Extracts the map defined with variable name `var` from the file `file`.

  Returns the complete list of all mapping tuples.
  """
  @spec extract(String.t, String.t) :: list
  def extract(var, file) do
    re_opts = [ :dotall, { :newline, :anycrlf }, :multiline, :ungreedy ]
    source  = File.read! file

    "\\$#{ var } = array\\((?<map>.*)\\);"
    |> Regex.compile!(re_opts)
    |> Regex.named_captures(source)
    |> Map.get("map", "")
    |> parse_source()
  end

  @doc """
  Writes yaml file for a list of short code mappings.
  """
  @spec write_yaml(list, String.t) :: :ok
  def write_yaml(map, file) do
    { :ok, _ } = file |> File.open([ :write ], fn (outfile) ->
      for { short, long } <- map do
        outfile |> IO.write("- \"#{ short }\": \"#{ long }\"\n")
      end
    end)

    :ok
  end


  defp mapping_to_tuple([ _, short, long ]), do: { short, long }

  defp parse_mapping(mapping) do
    "'(.+)' => '(.+)'"
    |> Regex.compile!()
    |> Regex.run(mapping)
    |> mapping_to_tuple()
  end

  defp parse_source(source) do
    source
    |> String.strip()
    |> String.split("\n")
    |> Enum.map( &parse_mapping/1 )
  end
end
