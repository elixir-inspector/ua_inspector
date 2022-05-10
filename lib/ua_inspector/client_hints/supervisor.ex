defmodule UAInspector.ClientHints.Supervisor do
  @moduledoc false

  use Supervisor

  alias UAInspector.ClientHints

  @doc false
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default)
  end

  @impl Supervisor
  def init(_state) do
    children = [
      ClientHints.Apps,
      ClientHints.Browsers
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
