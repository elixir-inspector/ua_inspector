defmodule ExAgent.Databases do
  @moduledoc """
  Module to coordinate individual parser databases.
  """

  use GenServer

  @ets_table :ex_agent


  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  def init(_) do
    :ets.new(@ets_table, [ :set, :protected, :named_table ])

    ExAgent.Database.Clients.init()
    ExAgent.Database.Devices.init()
    ExAgent.Database.Oss.init()

    :ets.insert(:ex_agent, [ clients: 0, devices: 0, oss: 0 ])

    { :ok, [] }
  end

  def terminate(_, _) do
    ExAgent.Database.Clients.terminate()
    ExAgent.Database.Devices.terminate()
    ExAgent.Database.Oss.terminate()

    :ets.delete(@ets_table)

    :ok
  end


  # GenServer callbacks

  def handle_call({ :load, path }, _from, state) do
    ExAgent.Database.Clients.load(path)
    ExAgent.Database.Devices.load(path)
    ExAgent.Database.Oss.load(path)

    { :reply, :ok, state }
  end


  # Convenience methods

  @doc """
  Sends a request to load a database to the internal server.
  """
  @spec load(String.t) :: :ok
  def load(path), do: GenServer.call(__MODULE__, { :load, path })

  @doc """
  Updates the database entry counter.

  Use only within server connection!
  """
  @spec update_counter(atom) :: atom
  def update_counter(counter), do: :ets.update_counter(@ets_table, counter, 1)
end
