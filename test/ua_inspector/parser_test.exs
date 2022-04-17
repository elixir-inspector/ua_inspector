defmodule UAInspector.ParserTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "handle incomplete yaml definitions" do
    agent = "Incomplete YAML entry without model"

    parsed = %Result{
      user_agent: agent,
      device: %Result.Device{brand: "Incomplete"}
    }

    assert ^parsed = UAInspector.parse(agent)
  end

  test "empty user agents" do
    refute UAInspector.bot?(nil)
    refute UAInspector.bot?("")

    refute UAInspector.desktop?(nil)
    refute UAInspector.desktop?("")

    refute UAInspector.hbbtv?(nil)
    refute UAInspector.hbbtv?("")

    refute UAInspector.shelltv?(nil)
    refute UAInspector.shelltv?("")

    assert %Result{user_agent: nil} = UAInspector.parse(nil)
    assert %Result{user_agent: ""} = UAInspector.parse("")

    assert %Result{user_agent: nil} = UAInspector.parse_client(nil)
    assert %Result{user_agent: ""} = UAInspector.parse_client("")
  end

  test "bot?" do
    bot_ua = "generic crawler agent"

    assert UAInspector.bot?(bot_ua)
    assert UAInspector.parse(bot_ua) |> UAInspector.bot?()

    regular_ua = "regular user agent"

    refute UAInspector.bot?(regular_ua)
    refute UAInspector.parse(regular_ua) |> UAInspector.bot?()
  end

  test "desktop?" do
    assert UAInspector.desktop?(
             "Mozilla/5.0 (X11; U; Linux i686; fr-fr) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/531.2+ Debian/squeeze (2.30.6-1) Epiphany/2.30.6"
           )

    refute UAInspector.desktop?("regular user agent")
    refute UAInspector.desktop?("generic crawler agent")

    refute UAInspector.desktop?(
             "Tiphone T67/1.0 Browser/wap2.0 Sync/SyncClient1.1 Profile/MIDP-2.0 Configuration/CLDC-1.1"
           )

    refute UAInspector.desktop?(
             "Mozilla/5.0 (X11; U; Linux x86_64; fa-ir) AppleWebKit/534.35 (KHTML, like Gecko)  Chrome/11.0.696.65 Safari/534.35 Puffin/2.10977AP"
           )
  end

  test "hbbtv?" do
    assert "1.1.1" = UAInspector.hbbtv?("agent containing HbbTV/1.1.1 (; ;) information")
    refute UAInspector.hbbtv?("generic user agent")
  end

  test "shelltv?" do
    assert UAInspector.shelltv?("agent containing Shell information")
    refute UAInspector.shelltv?("generic user agent")
  end

  test "parse" do
    agent =
      "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"

    parsed = %Result{
      user_agent: agent,
      browser_family: "Safari",
      client: %Result.Client{
        engine: "WebKit",
        engine_version: "537.51.1",
        name: "Mobile Safari",
        type: "browser",
        version: "7.0"
      },
      device: %Result.Device{brand: "Apple", model: "iPad", type: "tablet"},
      os: %Result.OS{name: "iOS", version: "7.0.4"},
      os_family: "iOS"
    }

    assert ^parsed = UAInspector.parse(agent)
  end

  test "parse unknown" do
    agent = "some unknown user agent"
    parsed = %Result{user_agent: agent}

    assert ^parsed = UAInspector.parse(agent)
  end

  test "parse_client" do
    agent = "generic crawler agentx"
    parsed = %Result{user_agent: agent}

    assert ^parsed = UAInspector.parse_client(agent)
  end
end
