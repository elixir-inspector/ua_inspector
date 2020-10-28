defmodule UAInspector.Parser.BrowserEngineTest do
  use ExUnit.Case, async: true

  test "#1" do
    agent = "Opera/9.80 (Windows NT 6.2; U; Edition Next; ru) Presto/2.11 Version/12.50"
    parsed = UAInspector.parse(agent)

    assert "Presto" == parsed.client.engine
  end

  test "#2" do
    agent =
      "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML like Gecko) Chrome/33.0.1750.91 Safari/537.36 OPR/20.0.1387.37 (Edition Next-Campaign 21)"

    parsed = UAInspector.parse(agent)

    assert "Blink" == parsed.client.engine
  end

  test "#3" do
    agent = "Mozilla/5.0 (Android; Tablet; rv:20.0) Gecko/20.0 Firefox/20.0"
    parsed = UAInspector.parse(agent)

    assert "Gecko" == parsed.client.engine
    assert "20.0" == parsed.client.engine_version
  end

  test "#4" do
    agent = "Mozilla/5.0 (Android; Linux armv7l; rv:10.0) Gecko/20120118 Firefox/10.0 Fennec/10.0"
    parsed = UAInspector.parse(agent)

    assert "Gecko" == parsed.client.engine
    assert "10.0" == parsed.client.engine_version
  end
end
