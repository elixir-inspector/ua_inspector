defmodule ExAgent.Server do
  use GenServer

  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: :ex_agent ])
  end

  def stop() do
    GenServer.call(:ex_agent, :stop)
  end

  def handle_call({ :parse, ua }, _from, state) do
    { :reply, ExAgent.Parser.parse(ua), state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }

  def terminate(_, _), do: :ok
end
