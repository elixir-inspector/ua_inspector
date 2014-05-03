defmodule ExAgent.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed ua" do
    ua = "test_ua"

    %ExAgent.Response{string: ua_string} = ua |> ExAgent.parse()

    assert ua_string == ua
  end

  test "chrome linux" do
    ua = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36"

    %ExAgent.Response{
      ua: %ExAgent.Response.UserAgent{family: ua_family}
    } = ua |> ExAgent.parse()

    assert ua_family == "chrome"
  end
end
