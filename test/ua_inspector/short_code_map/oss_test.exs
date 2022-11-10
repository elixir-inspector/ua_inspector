defmodule UAInspector.ShortCodeMap.OSsTest do
  use ExUnit.Case, async: true

  alias UAInspector.ShortCodeMap.OSs

  test "OS name" do
    assert "FED" = OSs.to_short("Fedora")
  end

  test "OS name not convertible" do
    name = "--unknown--"

    assert ^name = OSs.to_short(name)
  end

  test "find OS fuzzy" do
    assert OSs.find_fuzzy("WindowsRT")
    assert OSs.find_fuzzy("Windows RT")
    refute OSs.find_fuzzy("Windows-RT")
  end
end
