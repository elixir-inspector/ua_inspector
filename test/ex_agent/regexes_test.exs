defmodule ExAgent.RegexesTest do
  use ExAgent.TestHelper.Case, async: false

  test "invalid file yields error" do
    assert { :error, _ } = ExAgent.load_yaml("--does-not-exist--")
  end
end
