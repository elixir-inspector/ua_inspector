defmodule UAInspector.Application do
  @moduledoc """
  UAInspector Application
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: UAInspector.Supervisor ]
    children = [
      UAInspector.Pool.child_spec,

      supervisor(UAInspector.Database.Supervisor, []),
      supervisor(UAInspector.ShortCodeMap.Supervisor, [])
    ]

    Supervisor.start_link(children, options)
  end
end
