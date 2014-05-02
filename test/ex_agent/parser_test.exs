defmodule ExAgent.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed ua" do
    ua      = "test_ua"
    ua_info = ua |> ExAgent.parse()

    assert ua_info[:string] == ua

    %ExAgent.Device{family: device_family} = ua_info[:device]
    %ExAgent.OS{family: os_family}         = ua_info[:os]
    %ExAgent.UserAgent{family: ua_family}  = ua_info[:ua]

    assert device_family == :unknown
    assert os_family     == :unknown
    assert ua_family     == :unknown
  end

  test "chrome linux" do
    ua      = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"
    ua_info = ua |> ExAgent.parse()

    assert ua_info[:string] == ua

    %ExAgent.Device{family: device_family} = ua_info[:device]
    %ExAgent.OS{family: os_family}         = ua_info[:os]
    %ExAgent.UserAgent{family: ua_family}  = ua_info[:ua]

    assert device_family == :unknown
    assert os_family     == "linux"
    assert ua_family     == "chrome"
  end
end
