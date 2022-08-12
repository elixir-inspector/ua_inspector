defmodule UAInspector.Util.ClientHintMappingTest do
  use ExUnit.Case, async: true

  alias UAInspector.Util.ClientHintMapping

  test "modified browser if mapping found" do
    assert ClientHintMapping.browser_mapping("GooglE ChromE") == "Chrome"
  end

  test "unmodified browser if no mapping found" do
    assert ClientHintMapping.browser_mapping("DoesNotExist") == "DoesNotExist"
  end

  test "modified OS if mapping found" do
    assert ClientHintMapping.os_mapping("LinuX") == "GNU/Linux"
  end

  test "unmodified OS if no mapping found" do
    assert ClientHintMapping.os_mapping("DoesNotExist") == "DoesNotExist"
  end
end
