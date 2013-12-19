defmodule ExAgent.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed ua" do
    assert ExAgent.parse("test_ua")[:string] == "test_ua"
  end

  test "chrome linux" do
    ua = ExAgent.parse("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36")

    assert ua[:os][:family] == :linux
    assert ua[:ua][:family] == :chrome
  end
end
