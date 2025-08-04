defmodule UAInspector.Benchmark.ParseDevice do
  alias UAInspector.Parser.Device

  @agent_camera "Mozilla/5.0 (Linux; Android 4.3; EK-GC200 Build/JSS15J) AppleWebKit/537.36 (KHTML like Gecko) Chrome/35.0.1916.141 Mobile Safari/537.36"
  @agent_car_browser "Mozilla/5.0 (X11; u; Linux; C) AppleWebKit /533.3 (Khtml, like Gheko) QtCarBrowser Safari/533.3"
  @agent_console "Mozilla/5.0 (Linux; arm_64; Android 13; Retroid Pocket 4 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.96 YaBrowser/24.4.3.96.00 SA/3 Mobile Safari/537.36"
  @agent_mobile "Mozilla/5.0 (Linux; Android 12; en; VIMOQ P662LO Build/SP1A.210812.016) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.129 HiBrowser/v2.21.2.1 UWS/ Mobile Safari/537.36"
  @agent_portable_media_player "Mozilla/5.0 (Linux; Android 7.0; FiiO M6 Build/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/51.0.2704.91 Mobile Safari/537.36"
  @agent_shell_tv "Mozilla/5.0 (Linux; Android 4.4.4; LEBEN Shell VVH32L147G22LTY) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.101 Safari/537.36"
  @agent_television "Mozilla/5.0 (Linux armv7l) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.140 Safari/537.36 OPR/46.0.2207.0 OMI/4.21.2.50.Honey.136 HbbTV/1.5.1 (+DRM;WeByLoewe;SmartTV_2021;V0000.01.00E.L0209;50A683FEVS;SmartTV_2021;) FVC/5.0 (WeByLoewe;SmartTV_2021;) LaTivu_1.0.1_2021"
  @agent_unknown "match nothing"

  def run do
    Benchee.run(
      %{
        "Parse Device: camera" => fn -> %{type: "camera"} = Device.parse(@agent_camera, %{}) end,
        "Parse Device: car browser" => fn ->
          %{type: "car browser"} = Device.parse(@agent_car_browser, %{})
        end,
        "Parse Device: console" => fn ->
          %{type: "console"} = Device.parse(@agent_console, %{})
        end,
        "Parse Device: smartphone" => fn ->
          %{type: "smartphone"} = Device.parse(@agent_mobile, %{})
        end,
        "Parse Device: portable media player" => fn ->
          %{type: "portable media player"} = Device.parse(@agent_portable_media_player, %{})
        end,
        "Parse Device: tv" => fn -> %{type: "tv"} = Device.parse(@agent_television, %{}) end,
        "Parse Device: tv (shell tv)" => fn ->
          %{type: "tv"} = Device.parse(@agent_shell_tv, %{})
        end,
        "Parse Device: unknown" => fn -> %{type: :unknown} = Device.parse(@agent_unknown, %{}) end
      },
      formatters: [{Benchee.Formatters.Console, comparison: false}]
    )
  end
end

UAInspector.Benchmark.ParseDevice.run()
