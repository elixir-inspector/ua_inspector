defmodule ExAgent.Server do
  use GenServer

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: :ex_agent ])
  end

  def init(_) do
    :ets.new(:ex_agent,           [ :set,         :private, :named_table ])
    :ets.new(:ex_agent_rx_device, [ :ordered_set, :private, :named_table ])
    :ets.new(:ex_agent_rx_os,     [ :ordered_set, :private, :named_table ])
    :ets.new(:ex_agent_rx_ua,     [ :ordered_set, :private, :named_table ])

    :ets.insert(:ex_agent, [ device_count: 0, os_count: 0, ua_count: 0 ])

    { :ok, [] }
  end

  def stop() do
    GenServer.call(:ex_agent, :stop)
  end

  def handle_call({ :load_yaml, file }, _from, state) do
    { :reply, ExAgent.Regexes.load_yaml(file), state }
  end

  def handle_call({ :parse, ua }, _from, state) do
    { :reply, ExAgent.Parser.parse(ua), state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }

  def terminate(_, _) do
    :ets.delete(:ex_agent_rx_ua)
    :ets.delete(:ex_agent_rx_os)
    :ets.delete(:ex_agent_rx_device)
    :ets.delete(:ex_agent)
    :ok
  end
end
