defmodule UAInspector.Parser.ClientTest do
  use ExUnit.Case, async: true

  alias UAInspector.ClientHints
  alias UAInspector.Result

  test "#1" do
    agent = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; Xbox)"
    parsed = UAInspector.parse(agent)

    result = %Result.Client{
      engine: "Trident",
      engine_version: "5.0",
      name: "Internet Explorer",
      type: "browser",
      version: "9.0"
    }

    assert ^result = parsed.client
  end

  test "#2" do
    agent =
      "Mozilla/5.0 (X11; Linux x86_64; rv:10.0.12) Gecko/20130823 Firefox/10.0.11esrpre Iceape/2.7.12"

    parsed = UAInspector.parse(agent)

    result = %Result.Client{
      engine: "Gecko",
      engine_version: "10.0.12",
      name: "Iceape",
      type: "browser",
      version: "2.7.12"
    }

    assert ^result = parsed.client
  end

  test "engine version with leading zero in fourth place (x.y.z.0[0-9]+)" do
    agent =
      "Mozilla/5.0 (Linux; arm_64; Android 10; Mi Note 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.5765.05 Mobile Safari/537.36"

    parsed = UAInspector.parse(agent)

    result = %UAInspector.Result.Client{
      engine: "WebKit",
      engine_version: "537.36",
      name: "Chrome Mobile",
      type: "browser",
      version: "115.0.5765.05"
    }

    assert ^result = parsed.client
  end

  test "engine version with client hint version leading zero in fourth place (x.y.z.0[0-9]+)" do
    agent =
      "Mozilla/5.0 (Linux; arm_64; Android 10; Mi Note 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/1.0.123.01 Mobile Safari/537.36"

    client_hints =
      ClientHints.new([
        {"sec-ch-ua-full-version-list", ~s(" Not A;Brand";v="1.0.0.0", "Chrome";v="1.0.123.02")}
      ])

    parsed = UAInspector.parse(agent, client_hints)

    result = %UAInspector.Result.Client{
      engine: "WebKit",
      engine_version: "537.36",
      name: "Chrome Mobile",
      type: "browser",
      version: "1.0.123.02"
    }

    assert ^result = parsed.client
  end

  test "engine version with many parts in client hint version" do
    agent =
      "Mozilla/5.0 (Linux; arm_64; Android 10; Mi Note 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/1.0.123.02 Mobile Safari/537.36"

    client_hints =
      ClientHints.new([
        {"sec-ch-ua-full-version-list",
         ~s(" Not A;Brand";v="1.0.0.0", "Chrome";v="1.0.123.02.3.4.5")}
      ])

    parsed = UAInspector.parse(agent, client_hints)

    result = %UAInspector.Result.Client{
      engine: "WebKit",
      engine_version: "537.36",
      name: "Chrome Mobile",
      type: "browser",
      version: "1.0.123.02.3.4.5"
    }

    assert ^result = parsed.client
  end
end
