defmodule UAInspector.Parser.OSTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result

  test "#1" do
    agent  = "Mozilla/5.0 (X11; Intel Mac OS X) AppleWebKit/538.1 (KHTML, like Gecko) Safari/538.1 debian/unstable (3.8.2-5) Epiphany/3.8.2"
    parsed = UAInspector.parse(agent)
    result = %Result.OS{ name: "Debian" }

    assert parsed.os == result
  end
end
