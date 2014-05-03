defmodule ExAgent.Parser.UATest do
  use ExUnit.Case, async: true

  test "ua parts" do
    ua = "Mozilla/5.0 (compatible; MSIE 10.0; Windows Phone 8.0; Trident/6.0; IEMobile/10.0; ARM; Touch; NOKIA; Lumia 920)"

    %ExAgent.Response{
      ua: %ExAgent.Response.UA{
        family: ua_family,
        major:  ua_major,
        minor:  ua_minor,
        patch:  ua_patch,
      },
    } = ua |> ExAgent.parse()

    assert ua_family == "IEMobile"
    assert ua_major  == "10"
    assert ua_minor  == "0"
    assert ua_patch  == :unknown
  end
end
