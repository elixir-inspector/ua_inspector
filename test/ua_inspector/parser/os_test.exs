defmodule UAInspector.Parser.OSTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "#1" do
    agent  = "Mozilla/5.0 (X11; Intel Mac OS X) AppleWebKit/538.1 (KHTML, like Gecko) Safari/538.1 debian/unstable (3.8.2-5) Epiphany/3.8.2"
    parsed = UAInspector.parse(agent)
    result = %Result.OS{ name: "Debian" }

    assert parsed.os == result
  end

  test "#2" do
    agent  = "Mozilla/5.0 (Linux; Android 4.0.4; ALCATEL ONE TOUCH 997D Build/IMM76D) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
    parsed = UAInspector.parse(agent)
    result = %Result.OS{ name: "Android", version: "4.0.4" }

    assert parsed.os == result
  end
end
