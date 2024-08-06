defmodule UAInspector.Util.VersionTest do
  use ExUnit.Case, async: true

  alias UAInspector.Util.Version

  doctest Version, import: true

  test "compare canonicalized" do
    source = Path.expand("../../fixtures/versions.txt", __DIR__)
    specs = File.stream!(source)

    for spec <- specs do
      [v1, op, v2] = spec |> String.trim() |> String.split(" ")

      result = case op do
        "<" -> :lt
        ">" -> :gt
        "==" -> :eq
      end

      assert ^result = Version.compare_canonicalized(v1, v2)
    end
  end
end
