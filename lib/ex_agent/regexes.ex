defmodule ExAgent.Regexes do
  :ssl.start
  :inets.start

  # fetch regexes.yaml
  regexes_url = "https://raw.github.com/tobie/ua-parser/master/regexes.yaml"

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

  # parse yaml
  :application.start(:yamerl)

  regex_list =
       regexes_yaml
    |> :yamerl_constr.string([ :str_node_as_binary ])
    |> hd()

  # define access methods
  regex_list |> Enum.each(fn (parser) ->
    { type, regexes } = parser

    regex_maps = regexes |> Enum.map(fn (regex) ->
      raw = regex |> Enum.into( %{} )

      %ExAgent.Regex{
        regex:              raw |> Map.get("regex",              nil) |> Regex.compile!(),
        device_replacement: raw |> Map.get("device_replacement", nil),
        family_replacement: raw |> Map.get("family_replacement", nil),
        os_replacement:     raw |> Map.get("os_replacement",     nil),
        os_v1_replacement:  raw |> Map.get("os_v1_replacement",  nil),
        os_v2_replacement:  raw |> Map.get("os_v2_replacement",  nil),
        v1_replacement:     raw |> Map.get("v1_replacement",     nil),
        v2_replacement:     raw |> Map.get("v2_replacement",     nil)
      }
    end)

    case type do
      "device_parsers" ->
        @device_parsers regex_maps
        @spec get(Atom.t) :: ExAgent.Regex.t
        def get(:device), do: @device_parsers

      "os_parsers" ->
        @os_parsers regex_maps
        @spec get(Atom.t) :: ExAgent.Regex.t
        def get(:os), do: @os_parsers

      "user_agent_parsers" ->
        @user_agent_parsers regex_maps
        @spec get(Atom.t) :: ExAgent.Regex.t
        def get(:user_agent), do: @user_agent_parsers
    end
  end)

  @doc """
  Fallback method if get/1 called with invalid parameter
  or after compilation error.
  """
  def get(_) do
    IO.puts "Invalid parser type given or regexes.yaml failed to parse!"
    nil
  end
end
