defmodule Mix.Tasks.UaInspector.Download.DatabasesTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias Mix.Tasks.UaInspector.Download.Databases, as: MixTask

  setup_all do
    # setup internal testing webserver
    Application.ensure_all_started(:inets)

    fixture_path = Path.expand("../../../fixtures", __DIR__)

    httpd_opts = [
      port: 0,
      server_name: 'ua_inspector_test',
      server_root: String.to_charlist(fixture_path),
      document_root: String.to_charlist(fixture_path)
    ]

    {:ok, httpd_pid} = :inets.start(:httpd, httpd_opts)

    # configure app to use testing webserver
    remote_paths = Application.get_env(:ua_inspector, :remote_path)
    remote_internal = "http://localhost:#{:httpd.info(httpd_pid)[:port]}/"

    test_remote_path = [
      bot: remote_internal,
      browser_engine: remote_internal,
      client: remote_internal,
      device: remote_internal,
      os: remote_internal,
      vendor_fragment: remote_internal
    ]

    :ok = Application.put_env(:ua_inspector, :remote_path, test_remote_path)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :remote_path, remote_paths)
    end)
  end

  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console =
      capture_io(fn ->
        MixTask.run([])

        IO.write("n")
      end)

    assert String.contains?(console, "Download aborted")
  end

  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console =
      capture_io([capture_prompt: true], fn ->
        MixTask.run([])
      end)

    assert String.contains?(console, "Really download? [Yn]")
  end

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.expand("../../downloads", __DIR__)

    console =
      capture_io(fn ->
        Application.put_env(:ua_inspector, :database_path, test_path)
        MixTask.run(["--force"])
        Application.put_env(:ua_inspector, :database_path, orig_path)

        databases = [
          UAInspector.Database.Bots,
          UAInspector.Database.BrowserEngines,
          UAInspector.Database.Clients,
          UAInspector.Database.DevicesHbbTV,
          UAInspector.Database.DevicesRegular,
          UAInspector.Database.OSs,
          UAInspector.Database.VendorFragments
        ]

        for database <- databases do
          for {_type, local, _remote} <- database.sources do
            [test_path, local]
            |> Path.join()
            |> File.exists?()
            |> assert
          end
        end
      end)

    assert String.contains?(console, test_path)

    File.rm_rf!(test_path)
  end

  test "missing configuration" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)

    console =
      capture_io(:stderr, fn ->
        # capture regular output as well
        capture_io(fn ->
          Application.put_env(:ua_inspector, :database_path, nil)
          MixTask.run([])
          Application.put_env(:ua_inspector, :database_path, orig_path)
        end)
      end)

    assert String.contains?(console, "not configured")
  end
end
