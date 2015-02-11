defmodule UAInspectorTest do
  use ExUnit.Case, async: true

  test "unconfigured database path" do
    assert :ok == UAInspector.load(nil)
  end
end
