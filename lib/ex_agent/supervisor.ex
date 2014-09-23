defmodule ExAgent.Supervisor do
  @moduledoc """
  ExAgent supervisor.
  """

  use Supervisor

  @doc """
  Starts the supervisor.
  """
  @spec start_link() :: Supervisor.on_start
  def start_link() do
    Supervisor.start_link(__MODULE__, [], [])
  end

  def init([]) do
    [
      worker(ExAgent.Databases, []),
      ExAgent.Pool.child_spec
    ]
      |> supervise(strategy: :one_for_one)
  end
end
