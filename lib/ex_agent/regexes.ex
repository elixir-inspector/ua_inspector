defmodule ExAgent.Regexes do
  regexes_url = "https://raw.github.com/tobie/ua-parser/master/regexes.yaml"

  HTTPotion.start
  HTTPotion.Response[body: regexes_yaml] = regexes_url |> HTTPotion.get()

  unless nil == regexes_yaml do
    regexes = case :yaml.load(regexes_yaml) do
      { :ok, regexes } -> regexes
      { :error, err }  ->
        IO.puts "Failed to parse regexes.yaml: " <> inspect(err)
        nil
    end
  end

  unless nil == regexes do
    regexes |> hd() |> Enum.each(fn (parser) ->
      { type, regexes } = parser

      regexes = regexes |> Enum.map(fn (regex) ->
        raw = regex |> HashDict.new()

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
  end

  def get(_) do
    IO.puts "Invalid parser type given or regexes.yaml failed to parse!"
    nil
  end
end
