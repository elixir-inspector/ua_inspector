defmodule UAInspector.ClientHints.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.ClientHints

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

  test "log info when load fails (apps)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(ClientHints.Apps, :reload)
      end)

    assert log =~ ~r/Failed to load client hints #{@pathname}.*:enoent/
  end

  test "log info when load fails (browsers)" do
    log =
      capture_log(fn ->
        :ok = GenServer.call(ClientHints.Browsers, :reload)
      end)

    assert log =~ ~r/Failed to load client hints #{@pathname}.*:enoent/
  end
end
