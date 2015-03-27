defmodule UAInspector.Parser.DeviceTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "#1" do
    agent  = "Tiphone T67/1.0 Browser/wap2.0 Sync/SyncClient1.1 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ brand: "TiPhone", model: "T67", type: "smartphone" }

    assert parsed.device == result
  end

  test "#2" do
    agent  = "HbbTV/1.1.1 (+DL;TechnoTrend Goerler;S-855;3.1.8.24.04.20.devel;;) CE-HTML/1.0 hdplusinteraktiv/1.0 (NETRANGEMMH;)"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ type: "tv" }

    assert parsed.device == result
  end

  test "#3" do
    agent  = "HbbTV/1.1.1 (;;;;) Mozilla/5.0 (compatible; ANTGalio/3.0.2.1.22.43.08; Linux2.6.18-7.1/7405d0-smp)"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ brand: "Videoweb", model: "600S", type: "tv" }

    assert parsed.device == result
  end

  test "#4" do
    agent  = "Mozilla/5.0 (Android; Mobile; rv:22.0) Gecko/22.0 Firefox/22.0"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ type: "smartphone" }

    assert parsed.device == result
  end

  test "#5" do
    agent  = "Mozilla/5.0 (Android; Tablet; rv:20.0) Gecko/20.0 Firefox/20.0"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ type: "tablet" }

    assert parsed.device == result
  end

  test "#6" do
    agent  = "Mozilla/5.0 (Linux; U; Android 0.5; en-us) AppleWebKit/522+ (KHTML, like Gecko) Safari/419.3"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ type: "smartphone" }

    assert parsed.device == result
  end

  test "#7" do
    agent  = "Mozilla/5.0 (Linux; U; Android 3.1; pl-pl; K1 Build/K1_A301_03_03_110919_SG) AppleWebKit/534.13 (KHTML, like Gecko) Version/4.0 Safari/534.13"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ type: "tablet" }

    assert parsed.device == result
  end

  test "#8" do
    agent  = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; ARM; Trident/6.0; Touch; ARMBJS)"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ type: "tablet" }

    assert parsed.device == result
  end

  test "#9" do
    agent  = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0; Touch; MAARJS)"
    parsed = UAInspector.parse(agent)
    result = %Result.Device{ brand: "Acer", type: "tablet" }

    assert parsed.device == result
  end
end
