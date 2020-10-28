defmodule UAInspector.Downloader.ShortCodeMapConverterTest do
  use ExUnit.Case, async: true

  alias UAInspector.Downloader.ShortCodeMapConverter

  @fixture Path.expand("../../fixtures/ShortCodeMapConverterTest.php", __DIR__)

  test "extract :hash" do
    assert [
             {"AA", "A-Value"},
             {"BB", "B-Value"},
             {"CC", "C-Value"}
           ] = ShortCodeMapConverter.extract("hash", :hash, @fixture)
  end

  test "extract :hash_with_list" do
    assert [
             {"A-Value", ["AA"]},
             {"B-Value", ["BA", "BB"]}
           ] = ShortCodeMapConverter.extract("hashWithList", :hash_with_list, @fixture)
  end

  test "extract :list" do
    assert ["AA", "BB"] = ShortCodeMapConverter.extract("list", :list, @fixture)
  end
end
