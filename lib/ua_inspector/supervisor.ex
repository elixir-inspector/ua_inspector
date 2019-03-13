defmodule UAInspector.Supervisor do
  @moduledoc """
  UAInspector Supervisor.
  """

  use Supervisor

  alias UAInspector.Config

  @doc """
  Starts the supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start()
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_default) do
    :ok = Config.init_env()

    children = [
      supervisor(UAInspector.Database.Supervisor, []),
      supervisor(UAInspector.ShortCodeMap.Supervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
