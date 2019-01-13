defmodule UAInspector.Deprecations.SystemConfigTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.Config

  setup do
    app_path = Application.get_env(:ua_inspector, :database_path)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :database_path, app_path)
    end)
  end

  test "system environment configuration" do
    path = "/configuration/by/system/environment"
    var = "UA_INSPECTOR_CONFIG_TEST"

    Application.put_env(:ua_inspector, :database_path, {:system, var})
    System.put_env(var, path)

    log =
      capture_log(fn ->
        assert path == Config.database_path()
      end)

    assert log =~ ~r/deprecated/i
  end

  test "system environment configuration (with default)" do
    path = "/configuration/by/system/environment"
    var = "UA_INSPECTOR_CONFIG_TEST_DEFAULT"

    Application.put_env(:ua_inspector, :database_path, {:system, var, path})
    System.delete_env(var)

    log =
      capture_log(fn ->
        assert path == Config.database_path()
      end)

    assert log =~ ~r/deprecated/i
  end

  test "nested system environment access" do
    var = "UA_INSPECTOR_NESTED_CONFIG"
    val = "very-nested"

    System.put_env(var, val)

    Application.put_env(:ua_inspector, :test_only, deep: {:system, var})

    log =
      capture_log(fn ->
        assert [deep: val] == Config.get(:test_only)
        assert val == Config.get([:test_only, :deep])
      end)

    Application.delete_env(:ua_inspector, :test_only)

    assert log =~ ~r/deprecated/i
  end
end
