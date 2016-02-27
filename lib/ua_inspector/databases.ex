defmodule UAInspector.Databases do
  @moduledoc """
  Module to coordinate individual parser databases.
  """

  use GenServer

  alias UAInspector.Database


  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  def init(_) do
    _ = Database.Bots.init()
    _ = Database.BrowserEngines.init()
    _ = Database.Clients.init()
    _ = Database.Devices.init()
    _ = Database.OSs.init()
    _ = Database.VendorFragments.init()

    { :ok, [] }
  end


  # GenServer callbacks

  def handle_call({ :load, path }, _from, state) do
    :ok = Database.Bots.load(path)
    :ok = Database.BrowserEngines.load(path)
    :ok = Database.Clients.load(path)
    :ok = Database.Devices.load(path)
    :ok = Database.OSs.load(path)
    :ok = Database.VendorFragments.load(path)

    { :reply, :ok, state }
  end


  # Convenience methods

  @doc """
  Sends a request to load a database to the internal server.
  """
  @spec load(String.t) :: :ok
  def load(nil),  do: :ok
  def load(path), do: GenServer.call(__MODULE__, { :load, path })
end
