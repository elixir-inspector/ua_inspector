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
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_state) do
    children = [
      Database.Bots,
      Database.BrowserEngines,
      Database.Clients,
      Database.DevicesHbbTV,
      Database.DevicesRegular,
      Database.OSs,
      Database.VendorFragments
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
