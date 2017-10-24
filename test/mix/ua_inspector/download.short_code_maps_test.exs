defmodule Mix.UAInspector.ShortCodeMaps.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias UAInspector.Util

  setup_all do
    # setup internal testing webserver
    Application.ensure_all_started(:inets)

    fixture_path = Path.join([__DIR__, '../../fixtures']) |> Path.expand()

    httpd_opts = [
      port: 0,
      server_name: 'ua_inspector_test',
      server_root: Util.to_charlist(fixture_path),
      document_root: Util.to_charlist(fixture_path)
    ]

    {:ok, httpd_pid} = :inets.start(:httpd, httpd_opts)

    # configure app to use testing webserver
    remote_paths = Application.get_env(:ua_inspector, :remote_path)
    remote_internal = "http://localhost:#{:httpd.info(httpd_pid)[:port]}/"

    :ok = Application.put_env(:ua_inspector, :remote_path, short_code_map: remote_internal)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :remote_path, remote_paths)
    end)
  end

  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console =
      capture_io(fn ->
        Mix.UAInspector.Download.ShortCodeMaps.run([])

        IO.write("n")
      end)

    assert String.contains?(console, "Download aborted")
  end

  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console =
      capture_io([capture_prompt: true], fn ->
        Mix.UAInspector.Download.ShortCodeMaps.run([])
      end)

    assert String.contains?(console, "Really download? [Yn]")
  end

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.join(__DIR__, "../../downloads") |> Path.expand()

    console =
      capture_io(fn ->
        Application.put_env(:ua_inspector, :database_path, test_path)
        Mix.UAInspector.Download.ShortCodeMaps.run(["--force"])
        Application.put_env(:ua_inspector, :database_path, orig_path)

        maps = [
          UAInspector.ShortCodeMap.ClientBrowsers,
          UAInspector.ShortCodeMap.DeviceBrands,
          UAInspector.ShortCodeMap.MobileBrowsers,
          UAInspector.ShortCodeMap.OSs
        ]

        for map <- maps do
          [test_path, map.file_local]
          |> Path.join()
          |> File.exists?()
          |> assert
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
          Mix.UAInspector.Download.ShortCodeMaps.run([])
          Application.put_env(:ua_inspector, :database_path, orig_path)
        end)
      end)

    assert String.contains?(console, "not configured")
  end
end
