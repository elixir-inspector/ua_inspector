defmodule ExAgent do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    import Supervisor.Spec

    supervise([ worker(ExAgent.Server, []) ], strategy: :one_for_one)
  end

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: ExAgent.Response.t
  def parse(ua), do: GenServer.call(:ex_agent, { :parse, ua })
end
