defmodule UAInspector.Database.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias UAInspector.Database

  @pathname "something_that_does_not_exist"

  setup do
    app_path = Application.get_env(:ua_inspector, :database_path)

    Application.put_env(:ua_inspector, :database_path, @pathname)

    on_exit fn ->
      Application.put_env(:ua_inspector, :database_path, app_path)
    end
  end

  test "log info when load fails (bots)" do
    log = capture_io :user, fn ->
      Database.Bots.init(:ignored)
      Logger.flush()
    end

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (browser engines)" do
    log = capture_io :user, fn ->
      Database.BrowserEngines.init(:ignored)
      Logger.flush()
    end

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (clients)" do
    log = capture_io :user, fn ->
      Database.Clients.init(:ignored)
      Logger.flush()
    end

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (devices)" do
    log = capture_io :user, fn ->
      Database.Devices.init(:ignored)
      Logger.flush()
    end

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (operating systems)" do
    log = capture_io :user, fn ->
      Database.OSs.init(:ignored)
      Logger.flush()
    end

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end

  test "log info when load fails (vendor fragments)" do
    log = capture_io :user, fn ->
      Database.VendorFragments.init(:ignored)
      Logger.flush()
    end

    assert String.contains?(log, "failed")
    assert String.contains?(log, @pathname)
  end
end
