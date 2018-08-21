defmodule UAInspector.Database.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.Database

  @pathname "something_that_does_not_exist"

  setup do
    app_path = Application.get_env(:ua_inspector, :database_path)

    Application.put_env(:ua_inspector, :database_path, @pathname)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :database_path, app_path)
    end)
  end

  test "log info when load fails (bots)" do
    log =
      capture_log(fn ->
        Database.Bots.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (browser engines)" do
    log =
      capture_log(fn ->
        Database.BrowserEngines.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (clients)" do
    log =
      capture_log(fn ->
        Database.Clients.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (hbbtv devices)" do
    log =
      capture_log(fn ->
        Database.DevicesHbbTV.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (regular devices)" do
    log =
      capture_log(fn ->
        Database.DevicesRegular.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (operating systems)" do
    log =
      capture_log(fn ->
        Database.OSs.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (vendor fragments)" do
    log =
      capture_log(fn ->
        Database.VendorFragments.init(:ignored)
        :timer.sleep(100)
      end)

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end
end
