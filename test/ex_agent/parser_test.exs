defmodule ExAgent.ParserTest do
  use ExUnit.Case, async: true

  test "handle incomplete yaml definitions" do
    agent  = "Incomplete YAML entry without model"
    parsed = %{
      string: agent,
      client: :unknown,
      device: :unknown,
      os:     :unknown
    }

    assert parsed == ExAgent.parse(agent)
  end

  test "parse" do
    agent  = "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
    parsed = %{
      string: agent,
      client: %{ name: "Mobile Safari", version: "7.0" },
      device: %{ brand: "Apple", device: "tablet", model: "iPad" },
      os:     %{ name: "iOS", version: "7_0_4" },
    }

    assert parsed == ExAgent.parse(agent)
  end

  test "parse empty" do
    agent  = ""
    parsed = %{
      string: agent,
      client: :unknown,
      device: :unknown,
      os:     :unknown
    }

    assert parsed == ExAgent.parse(agent)
  end

  test "parse unknown" do
    agent  = "some unknown user agent"
    parsed = %{
      string: agent,
      client: :unknown,
      device: :unknown,
      os:     :unknown
    }

    assert parsed == ExAgent.parse(agent)
  end
end
