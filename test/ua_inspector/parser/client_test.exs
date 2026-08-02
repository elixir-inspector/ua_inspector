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

  test "engine reported via client hint brand list prefers Android WebView over Chromium" do
    client_hints =
      ClientHints.new([
        {"sec-ch-ua-full-version-list",
         ~s("Android WebView";v="115.0.5790.171", "Chromium";v="999.0.0.0", "Puffin";v="9.9")}
      ])

    parsed = UAInspector.parse("curl/7.68.0", client_hints)

    result = %UAInspector.Result.Client{
      engine: "Blink",
      engine_version: "115.0.5790.171",
      name: "Puffin",
      type: "browser",
      version: "9.9"
    }

    assert ^result = parsed.client
  end

  test "user agent engine version replaces a lower engine version reported by client hints" do
    agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.5993.70 Safari/537.36"

    client_hints =
      ClientHints.new([
        {"sec-ch-ua-full-version-list",
         ~s("Not A;Brand";v="8", "Chromium";v="50.0.1000.10", "Puffin";v="1.0")}
      ])

    parsed = UAInspector.parse(agent, client_hints)

    result = %UAInspector.Result.Client{
      engine: "Blink",
      engine_version: "118.0.5993.70",
      name: "Puffin",
      type: "browser",
      version: "1.0"
    }

    assert ^result = parsed.client
  end

  test "client hint engine version is restored when reduced below the reported brand version" do
    agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.1000.10 Safari/537.36"

    client_hints =
      ClientHints.new([
        {"sec-ch-ua-full-version-list",
         ~s("Not A;Brand";v="8", "Chromium";v="200.0.0.0", "Chrome";v="1.0")}
      ])

    parsed = UAInspector.parse(agent, client_hints)

    result = %UAInspector.Result.Client{
      engine: "Blink",
      engine_version: "200.0.0.0",
      name: "Chrome",
      type: "browser",
      version: "1.0"
    }

    assert ^result = parsed.client
  end

  test "client hint reported browser version is kept when more precise than user agent version" do
    agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.5000.10 Safari/537.36"

    client_hints =
      ClientHints.new([
        {"sec-ch-ua-full-version-list", ~s("Not A;Brand";v="8", "Chromium";v="118.0.9000.50")}
      ])

    parsed = UAInspector.parse(agent, client_hints)

    result = %UAInspector.Result.Client{
      engine: "Blink",
      engine_version: "118.0.9000.50",
      name: "Chrome",
      type: "browser",
      version: "118.0.9000.50"
    }

    assert ^result = parsed.client
  end
end
