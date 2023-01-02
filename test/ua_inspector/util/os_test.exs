defmodule UAInspector.Util.OSTest do
  use ExUnit.Case, async: true

  alias UAInspector.Result
  alias UAInspector.Util.OS

  doctest UAInspector.Util.OS, import: true

  test "check desktop only" do
    assert OS.desktop_only?("Debian")

    refute OS.desktop_only?("Android")
  end

  test "short code family lookup" do
    assert "Firefox OS" = OS.family("FOS")

    refute OS.family("XXX")
  end

  test "result family lookup" do
    assert "GNU/Linux" = OS.family_from_result(%Result.OS{name: "Debian"})

    assert :unknown = OS.family_from_result(%Result.OS{name: "Unknown OS"})
    assert :unknown = OS.family_from_result(%Result.OS{name: :unknown})
  end
end
