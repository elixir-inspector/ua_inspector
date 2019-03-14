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
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default, name: __MODULE__)
  end

  @doc false
  def init(_state) do
    :ok = Config.init_env()

    children = [
      UAInspector.Database.Supervisor,
      UAInspector.ShortCodeMap.Supervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
