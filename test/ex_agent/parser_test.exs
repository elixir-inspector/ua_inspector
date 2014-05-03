defmodule ExAgent.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed ua" do
    ua = "test_ua"

    %ExAgent.Response{string: ua_string} = ua |> ExAgent.parse()

    assert ua_string == ua
  end
end
