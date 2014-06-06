defmodule ExAgent.Regexes do
  @doc """
  Returns all regexes for the given type.
  """
  @spec get(Atom.t) :: [ ExAgent.Regex.t ]
  def get(:device), do: :ets.tab2list(:ex_agent_rx_device)
  def get(:os),     do: :ets.tab2list(:ex_agent_rx_os)
  def get(:ua),     do: :ets.tab2list(:ex_agent_rx_ua)
  def get(_type),   do: []

  @doc """
  Loads yaml file with user agent definitions.
  """
  @spec load_yaml(String.t) :: :ok | { :error, String.t }
  def load_yaml(file) do
    if File.regular?(file) do
      parse_yaml_file(file)
    else
      { :error, "Invalid file given: '#{ file }'" }
    end
  end

  defp parse_yaml_file(file) do
    :yamerl_constr.file(file, [ :str_node_as_binary ])
      |> hd()
      |> parse_yaml_data()
  end

  defp parse_yaml_data([]), do: :ok
  defp parse_yaml_data([ { type, regexes } | datasets ]) do
    store_regexes(type, regexes)
    parse_yaml_data(datasets)
  end

  defp store_regexes(_type, []), do: :ok
  defp store_regexes(type, [ regex | regexes ]) do
    raw = regex |> Enum.into( %{} )
    map = %ExAgent.Regex{
      regex:              raw["regex"] |> Regex.compile!(),
      device_replacement: raw["device_replacement"],
      family_replacement: raw["family_replacement"],
      os_replacement:     raw["os_replacement"],
      os_v1_replacement:  raw["os_v1_replacement"],
      os_v2_replacement:  raw["os_v2_replacement"],
      v1_replacement:     raw["v1_replacement"],
      v2_replacement:     raw["v2_replacement"]
    }

    store_regex(type, map)
    store_regexes(type, regexes)
  end

  defp store_regex("device_parsers", regex) do
    store_regex_object(:ex_agent_rx_device, :device_count, regex)
  end
  defp store_regex("os_parsers", regex) do
    store_regex_object(:ex_agent_rx_os, :os_count, regex)
  end
  defp store_regex("user_agent_parsers", regex) do
    store_regex_object(:ex_agent_rx_ua, :ua_count, regex)
  end

  defp store_regex_object(table, counter, object) do
    :ets.insert_new(
      table,
      { :ets.update_counter(:ex_agent, counter, 1), object }
    )
  end
end
