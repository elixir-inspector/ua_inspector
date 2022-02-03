defmodule UAInspector.Database.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.Database

  @pathname "something_that_does_not_exist"

  setup do
    database_path = Application.get_env(:ua_inspector, :database_path)

    Application.put_env(:ua_inspector, :database_path, @pathname)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :database_path, database_path)
    end)
  end

  test "log info when load fails (bots)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.Bots, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end

  test "log info when load fails (browser engines)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.BrowserEngines, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end

  test "log info when load fails (clients)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.Clients, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end

  test "log info when load fails (hbbtv devices)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.DevicesHbbTV, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end

  test "log info when load fails (regular devices)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.DevicesRegular, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end

  test "log info when load fails (operating systems)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.OSs, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end

  test "log info when load fails (shelltv devices)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.DevicesShellTV, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end

  test "log info when load fails (vendor fragments)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(Database.VendorFragments, :reload)
      end)

    assert log =~ ~r/Failed to load database #{@pathname}.*:enoent/
  end
end
