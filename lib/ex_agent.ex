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
  Loads yaml file with user agent definitions.
  """
  @spec load_yaml(String.t) :: :ok | { :error, String.t }
  def load_yaml(file), do: GenServer.call(:ex_agent, { :load_yaml, file })

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: ExAgent.Response.t
  def parse(ua), do: GenServer.call(:ex_agent, { :parse, ua })
end
