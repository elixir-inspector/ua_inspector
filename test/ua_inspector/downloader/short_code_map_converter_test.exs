defmodule UAInspector.Downloader.ShortCodeMapConverterTest do
  use ExUnit.Case, async: true

  alias UAInspector.Downloader.ShortCodeMapConverter

  @fixture Path.expand("../../fixtures/ShortCodeMapConverterTest.php", __DIR__)

  test "extract :hash" do
    expected = [
      {"AA", "A-Value"},
      {"BB", "B-Value"},
      {"CC", "C-Value"}
    ]

    assert ^expected = ShortCodeMapConverter.extract("hash", :hash, @fixture)
    assert ^expected = ShortCodeMapConverter.extract("hashLegacy", :hash, @fixture)
  end

  test "extract :hash_with_list" do
    expected = [
      {"A-Value", ["AA"]},
      {"B-Value", ["BA", "BB"]}
    ]

    assert ^expected = ShortCodeMapConverter.extract("hashWithList", :hash_with_list, @fixture)

    assert ^expected =
             ShortCodeMapConverter.extract("hashWithListLegacy", :hash_with_list, @fixture)

    assert ^expected =
             ShortCodeMapConverter.extract("hashWithListMultiline", :hash_with_list, @fixture)
  end

  test "extract :list" do
    expected = ["AA", "BB"]

    assert ^expected = ShortCodeMapConverter.extract("list", :list, @fixture)
    assert ^expected = ShortCodeMapConverter.extract("listLegacy", :list, @fixture)
    assert ^expected = ShortCodeMapConverter.extract("listMultiline", :list, @fixture)
  end
end
