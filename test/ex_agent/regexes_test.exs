defmodule ExAgent.RegexesTest do
  use ExUnit.Case, async: false
  use ExAgent.TestHelper.Suite

  test "invalid file yields error" do
    assert { :error, _ } = ExAgent.load_yaml("--does-not-exist--")
  end
end
