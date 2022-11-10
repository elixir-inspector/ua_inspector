defmodule UAInspector.ShortCodeMap.ClientBrowsersTest do
  use ExUnit.Case, async: true

  alias UAInspector.ShortCodeMap.ClientBrowsers

  test "client browser" do
    assert "PU" = ClientBrowsers.to_short("Puffin")
  end

  test "client browser not convertible" do
    browser = "--unknown--"

    assert ^browser = ClientBrowsers.to_short(browser)
  end

  test "find client browser fuzzy" do
    assert ClientBrowsers.find_fuzzy("Crazy Browser")
    assert ClientBrowsers.find_fuzzy("Crazy")
    assert ClientBrowsers.find_fuzzy("Puffin Browser")
    refute ClientBrowsers.find_fuzzy("Crazy-Browser")
  end
end
