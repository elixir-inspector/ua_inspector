defmodule UAInspector.ShortCodeMap.OSsTest do
  use ExUnit.Case, async: true

  alias UAInspector.ShortCodeMap.OSs

  test "OS name" do
    assert "Fedora" == OSs.to_long("FED")
    assert "FED" == OSs.to_short("Fedora")
  end

  test "OS name not convertible" do
    name = "--unknown--"

    assert name == OSs.to_long(name)
    assert name == OSs.to_short(name)
  end
end
