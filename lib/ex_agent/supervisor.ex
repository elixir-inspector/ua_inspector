defmodule ExAgent.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    supervise([ ExAgent.Pool.child_spec ], strategy: :one_for_one)
  end
end
