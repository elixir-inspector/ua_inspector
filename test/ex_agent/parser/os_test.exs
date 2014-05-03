defmodule ExAgent.Parser.OSTest do
  use ExUnit.Case, async: true

  test "os parts" do
    ua = "Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B206 Safari/7534.48.3"

    %ExAgent.Response{
      os: %ExAgent.Response.OS{
        family:      os_family,
        major:       os_major,
        minor:       os_minor,
        patch:       os_patch,
        patch_minor: os_patch_minor
      },
    } = ua |> ExAgent.parse()

    assert os_family      == "iOS"
    assert os_major       == "5"
    assert os_minor       == "1"
    assert os_patch       == "1"
    assert os_patch_minor == :unknown
  end
end
