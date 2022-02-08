defmodule UAInspector.Parser.ClientTest do
  use ExUnit.Case, async: true

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
end
