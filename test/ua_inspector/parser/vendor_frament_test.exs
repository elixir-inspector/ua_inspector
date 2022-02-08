defmodule UAInspector.Parser.VendorFragmentTest do
  use ExUnit.Case, async: true

  test "#1" do
    agent =
      "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/7.0; SLCC2; .NET CLR 2.0.50727; Media Center PC 6.0; MAAR; Tablet PC 2.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E)"

    parsed = UAInspector.parse(agent)

    assert "Acer" = parsed.device.brand
  end
end
