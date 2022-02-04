defmodule UAInspector.ShortCodeMap.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.ShortCodeMap

  @pathname "something_that_does_not_exist"

  setup do
    database_path = Application.get_env(:ua_inspector, :database_path)
    startup_silent = Application.get_env(:ua_inspector, :startup_silent)

    Application.put_env(:ua_inspector, :database_path, @pathname)
    Application.put_env(:ua_inspector, :startup_silent, false)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :database_path, database_path)
      Application.put_env(:ua_inspector, :startup_silent, startup_silent)
    end)
  end

  test "log info when load fails (client browsers)" do
    log =
      capture_log(fn ->
        GenServer.call(ShortCodeMap.ClientBrowsers, :reload)
      end)

    assert log =~ ~r/Failed to load short code map #{@pathname}.*:enoent/
  end

  test "log info when load fails (mobile browsers)" do
    log =
      capture_log(fn ->
        GenServer.call(ShortCodeMap.MobileBrowsers, :reload)
      end)

    assert log =~ ~r/Failed to load short code map #{@pathname}.*:enoent/
  end
end
