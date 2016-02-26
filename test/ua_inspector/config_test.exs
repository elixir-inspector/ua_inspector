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

    Application.put_env(:ua_inspector, :database_path, path)

    assert path == Config.database_path
  end

  test "system environment configuration" do
    path = "/configuration/by/system/environment"
    var  = "UA_INSPECTOR_CONFIG_TEST"

    Application.put_env(:ua_inspector, :database_path, { :system, var })
    System.put_env(var, path)

    assert path == Config.database_path
  end

  test "missing configuration" do
    Application.put_env(:ua_inspector, :database_path, nil)

    assert nil == Config.database_path
  end
end
