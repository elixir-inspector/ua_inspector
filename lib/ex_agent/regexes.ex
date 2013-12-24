defmodule ExAgent.Regexes do
  regexes = case :yaml.load_file("./vendor/ua-parser/regexes.yaml") do
    { :ok, regexes } -> regexes
    { :error, err }  ->
      IO.puts "Failed to load regexes.yaml: " <> inspect(err)
      nil
  end

  unless nil == regexes do
    regexes |> hd() |> Enum.each(fn (parser) ->
      { type, regexes } = parser

      parser_type = case type do
        "device_parsers"     -> :device
        "os_parsers"         -> :os
        "user_agent_parsers" -> :user_agent
      end

      def get(unquote(parser_type)), do: unquote(regexes)
    end)
  end

  def get(_) do
    IO.puts "Invalid parser type given or regexes.yaml failed to parse!"
    nil
  end
end
