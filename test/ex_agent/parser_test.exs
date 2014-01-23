defmodule ExAgent.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed ua" do
    ua      = "test_ua"
    ua_info = ua |> ExAgent.parse()

    assert ua_info[:string]          == ua
    assert ua_info[:device][:family] == :unknown
    assert ua_info[:os][:family]     == :unknown
    assert ua_info[:ua][:family]     == :unknown
  end

  test "chrome linux" do
    ua      = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"
    ua_info = ua |> ExAgent.parse()

    assert ua_info[:string]          == ua
    assert ua_info[:device][:family] == :unknown
    assert ua_info[:os][:family]     == "linux"
    assert ua_info[:ua][:family]     == "chrome"
  end
end
