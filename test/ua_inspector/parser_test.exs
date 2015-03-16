defmodule UAInspector.ParserTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "handle incomplete yaml definitions" do
    agent  = "Incomplete YAML entry without model"
    parsed = %Result{ user_agent: agent }

    assert parsed == UAInspector.parse(agent)
  end

  test "parse empty" do
    agent  = ""
    parsed = %Result{ user_agent: agent }

    assert parsed == UAInspector.parse(agent)
  end

  test "parse unknown" do
    agent  = "some unknown user agent"
    parsed = %Result{ user_agent: agent }

    assert parsed == UAInspector.parse(agent)
  end


  test "parse #1" do
    agent  = "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
    parsed = %Result{
      user_agent: agent,
      client:     %Result.Client{ engine: "WebKit", name: "Mobile Safari", type: "browser", version: "7.0" },
      device:     %Result.Device{ brand: "Apple", model: "iPad", type: "tablet" },
      os:         %Result.OS{ name: "iOS", version: "7.0.4" }
    }

    assert parsed == UAInspector.parse(agent)
  end


  test "parse client #1" do
    agent  = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; Xbox)"
    parsed = %Result{
      user_agent: agent,
      client:     %Result.Client{ engine: "Trident", name: "Internet Explorer", type: "browser", version: "9.0" },
      device:     :unknown,
      os:         :unknown
    }

    assert parsed == UAInspector.parse(agent)
  end


  test "parse device #1" do
    agent  = "Tiphone T67/1.0 Browser/wap2.0 Sync/SyncClient1.1 Profile/MIDP-2.0 Configuration/CLDC-1.1"
    parsed = %Result{
      user_agent: agent,
      client:     :unknown,
      device:     %Result.Device{ brand: "TiPhone", model: "T67", type: "smartphone" },
      os:         :unknown
    }

    assert parsed == UAInspector.parse(agent)
  end

  test "parse device #2" do
    agent  = "HbbTV/1.1.1 (+DL;TechnoTrend Goerler;S-855;3.1.8.24.04.20.devel;;) CE-HTML/1.0 hdplusinteraktiv/1.0 (NETRANGEMMH;)"
    parsed = %Result{
     user_agent: agent,
      client:     :unknown,
      device:     %Result.Device{ type: "tv" },
      os:         :unknown
    }

    assert parsed == UAInspector.parse(agent)
  end

  test "parse device #3" do
    agent  = "HbbTV/1.1.1 (;;;;) Mozilla/5.0 (compatible; ANTGalio/3.0.2.1.22.43.08; Linux2.6.18-7.1/7405d0-smp)"
    parsed = %Result{
      user_agent: agent,
      client:     :unknown,
      device:     %Result.Device{ brand: "Videoweb", model: "600S", type: "tv" },
      os:         :unknown
    }

    assert parsed == UAInspector.parse(agent)
  end


  test "parse browser engine #1" do
    agent  = "Opera/9.80 (Windows NT 6.2; U; Edition Next; ru) Presto/2.11 Version/12.50"
    parsed = UAInspector.parse(agent)

    assert "Presto" == parsed.client.engine
  end

  test "parse browser engine #2" do
    agent  = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML like Gecko) Chrome/33.0.1750.91 Safari/537.36 OPR/20.0.1387.37 (Edition Next-Campaign 21)"
    parsed = UAInspector.parse(agent)

    assert "Blink" == parsed.client.engine
  end
end
