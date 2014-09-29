defmodule ExAgent.Server do
  @moduledoc """
  ExAgent poolboy worker (server).
  """

  use GenServer

  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  def handle_call({ :parse, ua }, _from, state) do
    { :reply, ExAgent.Parser.parse(ua), state }
  end

  def handle_call(:stop, _from, state), do: { :stop, :normal, :ok, state }
end
