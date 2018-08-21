defmodule UAInspector.Database.Supervisor do
  @moduledoc """
  Supervisor for databases.
  """

  use Supervisor

  alias UAInspector.Database

  @doc """
  Starts the database supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start()
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_default) do
    children = [
      worker(Database.Bots, []),
      worker(Database.BrowserEngines, []),
      worker(Database.Clients, []),
      worker(Database.DevicesHbbTV, []),
      worker(Database.DevicesRegular, []),
      worker(Database.OSs, []),
      worker(Database.VendorFragments, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
