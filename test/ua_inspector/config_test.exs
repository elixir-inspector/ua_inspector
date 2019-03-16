defmodule UAInspector.ConfigTest do
  use ExUnit.Case, async: false

  alias UAInspector.Config

  setup do
    app_path = Application.get_env(:ua_inspector, :database_path)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :database_path, app_path)
    end)
  end

  test "application configuration" do
    path = "/configuration/by/application/configuration"
    url = "http://some.host/path/to/database"

    Application.put_env(:ua_inspector, :database_path, path)
    Application.put_env(:ua_inspector, :remote_path, foo: url)

    assert path == Config.database_path()
    assert "#{url}/bar.yml" == Config.database_url(:foo, "bar.yml")
  after
    Application.delete_env(:ua_inspector, :remote_path)
  end

  test "default database release configuration" do
    assert :bot
           |> Config.database_url("bot.yml")
           |> String.contains?("/device-detector/master")

    Application.put_env(:ua_inspector, :remote_release, "v1.0.0")

    assert :bot
           |> Config.database_url("bot.yml")
           |> String.contains?("/device-detector/v1.0.0")
  after
    Application.delete_env(:ua_inspector, :remote_release)
  end

  test "priv dir fallback for misconfiguration" do
    Application.put_env(:ua_inspector, :database_path, nil)

    refute nil == Config.database_path()
  end

  test "deep key access" do
    Application.put_env(:ua_inspector, :test_deep, deep: [foo: :bar])

    assert [deep: [foo: :bar]] == Config.get([:test_deep])
    assert :bar == Config.get([:test_deep, :deep, :foo])

    assert :moep == Config.get([:unknown, :deep], :moep)
  end
end
