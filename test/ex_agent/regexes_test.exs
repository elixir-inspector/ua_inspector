defmodule ExAgent.RegexesTest do
  use ExUnit.Case, async: true

  test "invalid file yields error" do
    assert { :error, _ } = ExAgent.load_yaml("--does-not-exist--")
  end
end
