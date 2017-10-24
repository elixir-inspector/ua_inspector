defmodule UAInspector.ParserTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "handle incomplete yaml definitions" do
    agent = "Incomplete YAML entry without model"

    parsed = %Result{
      user_agent: agent,
      device: %Result.Device{brand: "Incomplete"}
    }

    assert parsed == UAInspector.parse(agent)
  end

  test "empty user agents" do
    refute UAInspector.bot?(nil)
    refute UAInspector.bot?("")

    refute UAInspector.hbbtv?(nil)
    refute UAInspector.hbbtv?(nil)

    assert UAInspector.parse(nil) == %Result{user_agent: nil}
    assert UAInspector.parse("") == %Result{user_agent: ""}

    assert UAInspector.parse_client(nil) == %Result{user_agent: nil}
    assert UAInspector.parse_client("") == %Result{user_agent: ""}
  end

  test "bot?" do
    assert UAInspector.bot?("generic crawler agent")
    refute UAInspector.bot?("regular user agent")
  end

  test "hbbtv?" do
    assert "1.1.1" == UAInspector.hbbtv?("agent containing HbbTV/1.1.1 (; ;) information")
    refute UAInspector.hbbtv?("generic user agent")
  end

  test "parse" do
    agent =
      "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"

    parsed = %Result{
      user_agent: agent,
      client: %Result.Client{
        engine: "WebKit",
        engine_version: "537.51.1",
        name: "Mobile Safari",
        type: "browser",
        version: "7.0"
      },
      device: %Result.Device{brand: "Apple", model: "iPad", type: "tablet"},
      os: %Result.OS{name: "iOS", version: "7.0.4"}
    }

    assert parsed == UAInspector.parse(agent)
  end

  test "parse unknown" do
    agent = "some unknown user agent"
    parsed = %Result{user_agent: agent}

    assert parsed == UAInspector.parse(agent)
  end

  test "parse_client" do
    agent = "generic crawler agentx"
    parsed = %Result{user_agent: agent}

    assert parsed == UAInspector.parse_client(agent)
  end
end
