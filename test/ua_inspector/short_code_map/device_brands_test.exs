defmodule UAInspector.ShortCodeMap.DeviceBrandsTest do
  use ExUnit.Case, async: true

  alias UAInspector.ShortCodeMap.DeviceBrands

  test "device brand" do
    assert "Google" == DeviceBrands.to_long("GO")
    assert "GO"     == DeviceBrands.to_short("Google")
  end

  test "device brand not convertible" do
    brand = "--unknown--"

    assert brand == DeviceBrands.to_long(brand)
    assert brand == DeviceBrands.to_short(brand)
  end
end
