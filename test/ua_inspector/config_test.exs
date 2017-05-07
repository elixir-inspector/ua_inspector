defmodule UAInspector.ConfigTest do
  use ExUnit.Case, async: false

  alias UAInspector.Config

  setup do
    app_path = Application.get_env(:ua_inspector, :database_path)

    on_exit fn ->
      Application.put_env(:ua_inspector, :database_path, app_path)
    end
  end


  test "application configuration" do
    path = "/configuration/by/application/configuration"
    url  = "http://some.host/path/to/database"

    Application.put_env(:ua_inspector, :database_path, path)
    Application.put_env(:ua_inspector, :remote_path, [ foo: url ])

    assert path == Config.database_path
    assert "#{ url }/bar.yml" == Config.database_url(:foo, "bar.yml")
  end


  test "system environment configuration" do
    path = "/configuration/by/system/environment"
    var  = "UA_INSPECTOR_CONFIG_TEST"

    Application.put_env(:ua_inspector, :database_path, { :system, var })
    System.put_env(var, path)

    assert path == Config.database_path
  end

  test "system environment configuration (with default)" do
    path = "/configuration/by/system/environment"
    var  = "UA_INSPECTOR_CONFIG_TEST_DEFAULT"

    Application.put_env(:ua_inspector, :database_path, { :system, var, path })
    System.delete_env(var)

    assert path == Config.database_path
  end

  test "missing configuration" do
    Application.put_env(:ua_inspector, :database_path, nil)

    assert nil == Config.database_path
  end


  test "deep key access" do
    Application.put_env(:ua_inspector, :test_deep, [ deep: [ foo: :bar ]])

    assert [ deep: [ foo: :bar ]] == Config.get([ :test_deep])
    assert :bar == Config.get([ :test_deep, :deep, :foo ])

    assert :moep == Config.get([ :unknown, :deep ], :moep)
  end


  test "nested system environment access" do
    var = "UA_INSPECTOR_NESTED_CONFIG"
    val = "very-nested"

    System.put_env(var, val)

    Application.put_env(:ua_inspector, :test_only, deep: { :system, var })

    assert [ deep: val ] == Config.get(:test_only)
    assert val == Config.get([ :test_only, :deep ])

    Application.delete_env(:ua_inspector, :test_only)
  end
end
