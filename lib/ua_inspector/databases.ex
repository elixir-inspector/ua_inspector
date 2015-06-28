defmodule UAInspector.Databases do
  @moduledoc """
  Module to coordinate individual parser databases.
  """

  use GenServer

  alias UAInspector.Database

  @ets_table :ua_inspector_databases


  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  def init(_) do
    _tid = :ets.new(@ets_table, [ :set, :protected, :named_table ])

    Database.Bots.init()
    Database.BrowserEngines.init()
    Database.Clients.init()
    Database.Devices.init()
    Database.OSs.init()
    Database.VendorFragments.init()

    counters = [
      bots:             0,
      browser_engines:  0,
      clients:          0,
      devices:          0,
      oss:              0,
      vendor_fragments: 0
    ]

    :ets.insert(@ets_table, counters)

    { :ok, [] }
  end


  # GenServer callbacks

  def handle_call({ :load, path }, _from, state) do
    Database.Bots.load(path)
    Database.BrowserEngines.load(path)
    Database.Clients.load(path)
    Database.Devices.load(path)
    Database.OSs.load(path)
    Database.VendorFragments.load(path)

    { :reply, :ok, state }
  end


  # Convenience methods

  @doc """
  Sends a request to load a database to the internal server.
  """
  @spec load(String.t) :: :ok
  def load(nil),  do: :ok
  def load(path), do: GenServer.call(__MODULE__, { :load, path })

  @doc """
  Updates the database entry counter.

  Use only within server connection!
  """
  @spec update_counter(atom) :: integer
  def update_counter(counter), do: :ets.update_counter(@ets_table, counter, 1)
end
