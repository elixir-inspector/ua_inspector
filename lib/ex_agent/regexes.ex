defmodule ExAgent.Regexes do
  regexes_url = "https://raw.github.com/tobie/ua-parser/master/regexes.yaml"

  :ssl.start
  :inets.start

  headers = [ { 'user-agent', 'ExAgent/#{System.version}' } ]
  request = { :binary.bin_to_list(regexes_url), headers }

  regexes_yaml = case :httpc.request(:get, request, [], body_format: :binary) do
    { :ok, {{_, status, _}, _, body} } when status in 200..299 ->
      body
    { :ok, {{_, status, _}, _, _} } ->
      raise "Failed to download #{ regexes_url }, status: #{ status }"
    { :error, reason } ->
      raise "Failed to download #{ regexes_url }, error: #{ reason }"
  end

  regexes = case :yaml.load(regexes_yaml) do
    { :ok, regexes }   -> regexes
    { :error, reason } -> raise "Failed to parse regexes.yaml: #{ reason }"
  end

  regexes |> hd() |> Enum.each(fn (parser) ->
    { type, regexes } = parser

    regexes = regexes |> Enum.map(fn (regex) ->
      raw = regex |> Enum.into( HashDict.new() )

      HashDict.new()
        |> HashDict.put(:regex, raw |> HashDict.get("regex", nil) |> Regex.compile!())
        |> HashDict.put(:device_replacement, raw |> HashDict.get("device_replacement", nil))
        |> HashDict.put(:family_replacement, raw |> HashDict.get("family_replacement", nil))
        |> HashDict.put(:os_replacement, raw |> HashDict.get("os_replacement", nil))
        |> HashDict.put(:os_v1_replacement, raw |> HashDict.get("os_v1_replacement", nil))
        |> HashDict.put(:os_v2_replacement, raw |> HashDict.get("os_v2_replacement", nil))
        |> HashDict.put(:v1_replacement, raw |> HashDict.get("v1_replacement", nil))
        |> HashDict.put(:v2_replacement, raw |> HashDict.get("v2_replacement", nil))
    end)

    case type do
      "device_parsers" ->
        @device_parsers regexes
        def get(:device), do: @device_parsers

      "os_parsers" ->
        @os_parsers regexes
        def get(:os), do: @os_parsers

      "user_agent_parsers" ->
        @user_agent_parsers regexes
        def get(:user_agent), do: @user_agent_parsers
    end
  end)

  def get(_) do
    IO.puts "Invalid parser type given or regexes.yaml failed to parse!"
    nil
  end
end
