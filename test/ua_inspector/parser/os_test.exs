defmodule UAInspector.Parser.OSTest do
  use ExUnit.Case, async: true

  alias UAInspector.ClientHints
  alias UAInspector.Result

  test "#1" do
    agent =
      "Mozilla/5.0 (X11; Intel Mac OS X) AppleWebKit/538.1 (KHTML, like Gecko) Safari/538.1 debian/unstable (3.8.2-5) Epiphany/3.8.2"

    parsed = UAInspector.parse(agent)
    result = %Result.OS{name: "Debian"}

    assert ^result = parsed.os
  end

  test "#2" do
    agent =
      "Mozilla/5.0 (Linux; Android 4.4.2; Omega 5.0 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36 GSA/3.4.16.1149292.arm"

    parsed = UAInspector.parse(agent)
    result = %Result.OS{name: "Android", platform: "ARM", version: "4.4.2"}

    assert ^result = parsed.os
  end

  test "puffin os version is read from the user agent instead of client hints" do
    agent =
      "Mozilla/5.0 (Cloud Phone 2.4; Nokia 225 4G; UNISOC) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.6834.210 Mobile Safari/537.36 Puffin/132.0.8.80800FP"

    client_hints =
      ClientHints.new([
        {"sec-ch-ua-platform", "Cloud Phone 2.4"},
        {"sec-ch-ua-platform-version", "132"}
      ])

    parsed = UAInspector.parse(agent, client_hints)

    result = %Result.OS{name: "Puffin OS", platform: :unknown, version: "2.4"}

    assert ^result = parsed.os
  end
end
