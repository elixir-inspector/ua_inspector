defmodule UAInspector.ShortCodeMap.Supervisor do
  @moduledoc false

  use Supervisor

  alias UAInspector.ShortCodeMap

  @doc """
  Starts the short code map supervisor.
  """
  @spec start_link(term) :: Supervisor.on_start()
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default)
  end

  @doc false
  def init(_state) do
    children = [
      ShortCodeMap.ClientBrowsers,
      ShortCodeMap.DesktopFamilies,
      ShortCodeMap.DeviceBrands,
      ShortCodeMap.MobileBrowsers,
      ShortCodeMap.OSFamilies,
      ShortCodeMap.OSs
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
