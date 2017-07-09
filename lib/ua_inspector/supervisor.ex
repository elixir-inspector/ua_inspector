defmodule UAInspector.Supervisor do
  @moduledoc """
  UAInspector Supervisor.
  """

  use Supervisor


  @doc """
  Starts the supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_default) do
    options  = [ strategy: :one_for_one, name: UAInspector.Supervisor ]
    children = [
      UAInspector.Pool.child_spec,

      supervisor(UAInspector.Database.Supervisor, []),
      supervisor(UAInspector.ShortCodeMap.Supervisor, [])
    ]

    supervise(children, options)
  end
end
