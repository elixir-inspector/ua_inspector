defmodule UAInspector.ParserTest do
  use ExUnit.Case, async: true

  alias UAInspector.ClientHints
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

    refute UAInspector.mobile?(nil)
    refute UAInspector.mobile?("")

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
    hbbtv_ua = "agent containing HbbTV/1.1.1 (; ;) information"
    regular_ua = "generic user agent"
    bot_ua = "generic bot"

    assert "1.1.1" = UAInspector.hbbtv?(hbbtv_ua)
    assert "1.1.1" = UAInspector.parse(hbbtv_ua) |> UAInspector.hbbtv?()

    refute UAInspector.hbbtv?(regular_ua)
    refute UAInspector.parse(regular_ua) |> UAInspector.hbbtv?()

    refute UAInspector.hbbtv?(bot_ua)
    refute UAInspector.parse(bot_ua) |> UAInspector.hbbtv?()
  end

  test "mobile?" do
    refute UAInspector.mobile?(
             "Mozilla/5.0 (X11; U; Linux i686; fr-fr) AppleWebKit/531.2+ (KHTML, like Gecko) Version/5.0 Safari/531.2+ Debian/squeeze (2.30.6-1) Epiphany/2.30.6"
           )

    refute UAInspector.mobile?("regular user agent")
    assert UAInspector.mobile?("regular user agent", %ClientHints{mobile: true})
    refute UAInspector.mobile?("regular user agent", %ClientHints{mobile: false})

    refute UAInspector.mobile?("generic crawler agent")

    assert UAInspector.mobile?(
             "Mozilla/5.0 (X11; U; Linux x86_64; fa-ir) AppleWebKit/534.35 (KHTML, like Gecko)  Chrome/11.0.696.65 Safari/534.35 Puffin/2.10977AP"
           )

    assert UAInspector.mobile?(
             "Tiphone T67/1.0 Browser/wap2.0 Sync/SyncClient1.1 Profile/MIDP-2.0 Configuration/CLDC-1.1"
           )
  end

  test "shelltv?" do
    shelltv_ua = "agent containing Shell information"
    regular_ua = "generic user agent"
    bot_ua = "generic bot"

    assert UAInspector.shelltv?(shelltv_ua)
    assert UAInspector.parse(shelltv_ua) |> UAInspector.shelltv?()

    refute UAInspector.shelltv?(regular_ua)
    refute UAInspector.parse(regular_ua) |> UAInspector.shelltv?()

    refute UAInspector.shelltv?(bot_ua)
    refute UAInspector.parse(bot_ua) |> UAInspector.shelltv?()
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

  test "parse form factor header" do
    header_type_map = [
      {~s("EInk", "Watch"), "wearable"},
      {~s("EInk"), "tablet"},
      {~s("Desktop", "Mobile"), "smartphone"},
      {~s("Unknown Type", "Mobile"), "smartphone"},
      {~s("Tablet", "Mobile"), "smartphone"},
      {~s("EInk", "Tablet"), "tablet"},
      {~s("Tablet", "Automotive"), "car browser"},
      {~s("EInk", "Xr"), "wearable"}
    ]

    for {form_factors_header, device_type} <- header_type_map do
      client_hints =
        ClientHints.new([
          {"sec-ch-ua-form-factors", form_factors_header},
          {"sec-ch-ua-model", ~s("Some Unknown Model")}
        ])

      assert %{device: %{brand: :unknown, model: "Some Unknown Model", type: ^device_type}} =
               UAInspector.parse("Some Unknown UA", client_hints)
    end
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

  describe "parser fixups" do
    test "is_android_tv" do
      agent =
        "Mozilla/5.0 (Linux; Android 9; TEST-XXXX Build/PPR2.180905.006.A1; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.120 YaBrowser/22.8.0.12 (lite) TV Safari/537.36"

      parsed = %Result{
        browser_family: "Chrome",
        client: %Result.Client{
          engine: "Blink",
          engine_version: "83.0.4103.120",
          name: "Chrome",
          type: "browser",
          version: :unknown
        },
        device: %Result.Device{brand: :unknown, model: :unknown, type: "tv"},
        user_agent: agent
      }

      assert ^parsed = UAInspector.parse(agent)
    end
  end
end
