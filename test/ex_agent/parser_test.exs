defmodule ExAgent.ParserTest do
  use ExUnit.Case, async: true

  test "retain unparsed ua" do
    assert "test_ua" == ExAgent.parse("test_ua")[:string]
  end
end
