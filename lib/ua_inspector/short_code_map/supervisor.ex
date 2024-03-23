defmodule UAInspector.ShortCodeMap.Supervisor do
  @moduledoc false

  use Supervisor

  alias UAInspector.ShortCodeMap

  @doc false
  def start_link(default \\ nil) do
    Supervisor.start_link(__MODULE__, default)
  end

  @impl Supervisor
  def init(_state) do
    children = [
      ShortCodeMap.BrowserFamilies,
      ShortCodeMap.ClientBrowsers,
      ShortCodeMap.ClientHintBrowserMapping,
      ShortCodeMap.ClientHintOSMapping,
      ShortCodeMap.DesktopFamilies,
      ShortCodeMap.MobileBrowsers,
      ShortCodeMap.OSFamilies,
      ShortCodeMap.OSs,
      ShortCodeMap.VersionMappingFireOS,
      ShortCodeMap.VersionMappingLineageOS
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
