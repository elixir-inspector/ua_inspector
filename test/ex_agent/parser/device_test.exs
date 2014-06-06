defmodule ExAgent.Parser.DeviceTest do
  use ExUnit.Case, async: false
  use ExAgent.TestHelper.Suite

  test "family replacement" do
    ua = " Mozilla/5.0 (Linux; U; Android 2.1; es-es; HTC Legend 1.23.161.1 Build/ERD79) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Mobile Safari/530.17,gzip"

    %ExAgent.Response{
      device: %ExAgent.Response.Device{family: device_family},
    } = ua |> ExAgent.parse()

    assert device_family == "HTC Legend"
  end
end
