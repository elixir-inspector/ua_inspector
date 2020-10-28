defmodule UAInspector.Parser.DeviceTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "#1" do
    agent =
      "Tiphone T67/1.0 Browser/wap2.0 Sync/SyncClient1.1 Profile/MIDP-2.0 Configuration/CLDC-1.1"

    parsed = UAInspector.parse(agent)
    result = %Result.Device{brand: "TiPhone", model: "T67", type: "smartphone"}

    assert parsed.device == result
  end

  test "#2" do
    agent =
      "HbbTV/1.1.1 (+DL;TechnoTrend Goerler;S-855;3.1.8.24.04.20.devel;;) CE-HTML/1.0 hdplusinteraktiv/1.0 (NETRANGEMMH;)"

    parsed = UAInspector.parse(agent)
    result = %Result.Device{type: "tv"}

    assert parsed.device == result
  end

  test "#3" do
    agent =
      "HbbTV/1.1.1 (;;;;) Mozilla/5.0 (compatible; ANTGalio/3.0.2.1.22.43.08; Linux2.6.18-7.1/7405d0-smp)"

    parsed = UAInspector.parse(agent)
    result = %Result.Device{brand: "Videoweb", model: "600S", type: "tv"}

    assert parsed.device == result
  end

  test "#4" do
    agent = "Mozilla/5.0 (Android; Mobile; rv:22.0) Gecko/22.0 Firefox/22.0"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{type: "smartphone"}

    assert parsed.device == result
  end

  test "#5" do
    agent = "Mozilla/5.0 (Android; Tablet; rv:20.0) Gecko/20.0 Firefox/20.0"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{type: "tablet"}

    assert parsed.device == result
  end

  test "#6" do
    agent =
      "Mozilla/5.0 (Linux; U; Android 0.5; en-us) AppleWebKit/522+ (KHTML, like Gecko) Safari/419.3"

    parsed = UAInspector.parse(agent)
    result = %Result.Device{type: "smartphone"}

    assert parsed.device == result
  end

  test "#7" do
    agent =
      "Mozilla/5.0 (Linux; U; Android 3.1; pl-pl; K1 Build/K1_A301_03_03_110919_SG) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13"

    parsed = UAInspector.parse(agent)
    result = %Result.Device{type: "tablet"}

    assert parsed.device == result
  end

  test "#8" do
    agent = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; ARM; Trident/6.0; Touch; ARMBJS)"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{type: "tablet"}

    assert parsed.device == result
  end

  test "#9" do
    agent =
      "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0; Touch; MAARJS)"

    parsed = UAInspector.parse(agent)
    result = %Result.Device{brand: "Acer", type: "tablet"}

    assert parsed.device == result
  end

  test "#10" do
    agent =
      "Bird-Doeasy E700_TD/S100 Linux/3.0.8 Android/4.0.3 Release/03.12.2013 Browser/AppleWebkit534.30 Mobile Safari/534.30;"

    parsed = UAInspector.parse(agent)

    assert "smartphone" == parsed.device.type
  end

  test "#11" do
    agent =
      "SonyEricssonU1i/R1CA; Mozilla/5.0 (SymbianOS/9.4; U; Series60/5.0 Profile/MIDP-2.1 Configuration/CLDC-1.1) AppleWebKit/525 (KHTML, like Gecko) Version/3.0 Safari/525"

    parsed = UAInspector.parse(agent)

    assert "feature phone" == parsed.device.type
  end

  test "#12" do
    agent = "CorePlayer/1.0 (Palm OS 5.4.9; ARM Intel PXA27x; en) CorePlayer/1.3.2_6909"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{brand: "Palm", type: "smartphone"}

    assert parsed.device == result
  end

  test "#13" do
    agent =
      "Opera/9.80 (Linux mips; Opera TV Store/5477) Presto/2.12.362 Version/12.10 Model/Changhong-MST6328"

    parsed = UAInspector.parse(agent)

    result = %Result.Device{type: "tv"}

    assert parsed.device == result
  end

  test "#14" do
    agent =
      "Mozilla/5.0 (Linux; Android 4.4.2; BUSH 5 Android Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36 [FB_IAB/FB4A;FBAV/54.0.0.23.62;]"

    parsed = UAInspector.parse(agent)

    assert "smartphone" == parsed.device.type
  end

  test "#15" do
    agent =
      "Mozilla/5.0 (Linux; Android 4.4; CT1000 Build/KRT16S) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.76 Safari/537.36"

    parsed = UAInspector.parse(agent)

    assert "tablet" == parsed.device.type
  end

  test "#16" do
    agent =
      "Mozilla/5.0 (Linux; Android 4.4; CT1000 Build/KRT16S) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36"

    parsed = UAInspector.parse(agent)

    assert :unknown == parsed.device
  end

  test "#17" do
    agent =
      "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2) Gecko/20100222 Firefox/3.6 Kylo/0.6.1.70394"

    parsed = UAInspector.parse(agent)

    assert parsed.device.type == "tv"
    assert parsed.client.name == "Kylo"
  end

  test "#18" do
    agent =
      "Mozilla/5.0 (DTV) AppleWebKit/531.2+ (KHTML, like Gecko) Espial/6.1.12 AQUOSBrowser/1.0 (AS00DTV;V;0001;0001)AQUOS-AS/2.0 LC-60UQ10E"

    parsed = UAInspector.parse(agent)

    assert parsed.device.type == "tv"
    assert parsed.client.name == "Espial TV Browser"
  end

  test "#19" do
    agent =
      "Opera/9.80 (Android 2.2.1; Linux; Opera Tablet/ADR-1301080958) Presto/2.11.355 Version/12.10"

    parsed = UAInspector.parse(agent)

    assert parsed.device.type == "tablet"
  end

  test "#20" do
    agent = "Mozilla/5.0 (Windows NT 10.0.16299.125; osmeta 10.3.3308) AppleWebKit/602.1.1 (KHTML, like Gecko) Version/9.0 Safari/602.1.1 osmeta/10.3.3308 Build/3308 [FBAN/FBW;FBAV/140.0.0.232.179;FBBV/83145113;FBDV/WindowsDevice;FBMD/TH360R12.32CTW;FBSN/Windows;FBSV/10.0.16299.192;FBSS/1;FBCR/;FBID/desktop;FBLC/fr_FR;FBOP/45;FBRV/0]"
    parsed = UAInspector.parse(agent)

    assert parsed.device.type == "desktop"
  end
end
