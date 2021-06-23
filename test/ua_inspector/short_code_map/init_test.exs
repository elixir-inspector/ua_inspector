defmodule UAInspector.ShortCodeMap.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.ShortCodeMap

  @pathname "something_that_does_not_exist"

  setup do
    app_path = Application.get_env(:ua_inspector, :database_path)
    startup = Application.get_env(:ua_inspector, :startup_sync)

    Application.put_env(:ua_inspector, :database_path, @pathname)
    Application.put_env(:ua_inspector, :startup_sync, false)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :database_path, app_path)
      Application.put_env(:ua_inspector, :startup_sync, startup)
    end)
  end

  test "log info when load fails (client browsers)" do
    log =
      capture_log(fn ->
        ShortCodeMap.ClientBrowsers.init(:ignored)
        :timer.sleep(100)
      end)

    assert log =~ ~r/Failed to load short code map #{@pathname}.*:enoent/
  end

  test "log info when load fails (mobile browsers)" do
    log =
      capture_log(fn ->
        ShortCodeMap.MobileBrowsers.init(:ignored)
        :timer.sleep(100)
      end)

    assert log =~ ~r/Failed to load short code map #{@pathname}.*:enoent/
  end
end
