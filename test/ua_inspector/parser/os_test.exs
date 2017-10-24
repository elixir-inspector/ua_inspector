defmodule UAInspector.Parser.OSTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "#1" do
    agent =
      "Mozilla/5.0 (X11; Intel Mac OS X) AppleWebKit/538.1 (KHTML, like Gecko) Safari/538.1 debian/unstable (3.8.2-5) Epiphany/3.8.2"

    parsed = UAInspector.parse(agent)
    result = %Result.OS{name: "Debian"}

    assert parsed.os == result
  end

  test "#2" do
    agent =
      "Mozilla/5.0 (Linux; Android 4.4.2; Omega 5.0 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36 GSA/3.4.16.1149292.arm"

    parsed = UAInspector.parse(agent)
    result = %Result.OS{name: "Android", platform: "ARM", version: "4.4.2"}

    assert parsed.os == result
  end
end
