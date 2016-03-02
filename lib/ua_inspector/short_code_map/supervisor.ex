defmodule UAInspector.ShortCodeMap.Supervisor do
  @moduledoc """
  Supervisor for short code maps.
  """

  use Supervisor

  alias UAInspector.ShortCodeMap

  @doc """
  Starts the short code map supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start
  def start_link(default \\ []) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_default) do
    children = [
      worker(ShortCodeMap.DeviceBrands, []),
      worker(ShortCodeMap.OSs, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end