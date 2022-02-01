defmodule UAInspector.Database.Supervisor do
  @moduledoc false

  use Supervisor

  alias UAInspector.Database

  @doc false
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default)
  end

  @impl Supervisor
  def init(_state) do
    children = [
      Database.Bots,
      Database.BrowserEngines,
      Database.Clients,
      Database.DevicesHbbTV,
      Database.DevicesNotebooks,
      Database.DevicesRegular,
      Database.DevicesShellTV,
      Database.OSs,
      Database.VendorFragments
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
