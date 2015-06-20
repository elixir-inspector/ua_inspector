defmodule UAInspector.ShortCodeTest do
  use ExUnit.Case, async: true

  alias UAInspector.ShortCode

  test "device brand" do
    assert "Google" == ShortCode.device_brand("GO", :long)
    assert "GO"     == ShortCode.device_brand("Google", :short)
  end

  test "device brand not convertible" do
    brand = "--unknown--"

    assert brand == ShortCode.device_brand(brand, :ignore)
    assert brand == ShortCode.device_brand(brand, :long)
    assert brand == ShortCode.device_brand(brand, :short)
  end
end
