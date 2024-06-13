defmodule Mix.Tasks.UaInspector.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias Mix.Tasks.UaInspector.Download, as: MixTask

  setup_all do
    fixture_path = Path.expand("../../../fixtures/repository", __DIR__)

    httpd_opts = [
      port: 0,
      server_name: ~c"ua_inspector_test",
      server_root: String.to_charlist(fixture_path),
      document_root: String.to_charlist(fixture_path)
    ]

    {:ok, httpd_pid} = :inets.start(:httpd, httpd_opts)

    # configure app to use testing webserver
    remote_paths = Application.get_env(:ua_inspector, :remote_path)
    remote_internal = "http://localhost:#{:httpd.info(httpd_pid)[:port]}/"

    test_remote_path = [
      bot: remote_internal <> "/regexes",
      browser_engine: remote_internal <> "/regexes/client",
      client: remote_internal <> "/regexes/client",
      client_hints: remote_internal <> "/regexes/client/hints",
      device: remote_internal <> "/regexes/device",
      os: remote_internal <> "/regexes",
      short_code_map: remote_internal,
      vendor_fragment: remote_internal <> "/regexes"
    ]

    :ok = Application.put_env(:ua_inspector, :remote_path, test_remote_path)

    on_exit(fn ->
      Application.put_env(:ua_inspector, :remote_path, remote_paths)

      :inets.stop(:httpd, httpd_pid)
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

  test "aborted download (quiet)" do
    Mix.shell(Mix.Shell.IO)

    console =
      capture_io(fn ->
        MixTask.run(["--quiet"])
        IO.write("n")
      end)

    assert "Download databases? [Yn] n" = console
  end

  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console =
      capture_io([capture_prompt: true], fn ->
        MixTask.run([])
      end)

    assert String.contains?(console, "Download databases? [Yn]")
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

        client_hints = [
          UAInspector.ClientHints.Apps,
          UAInspector.ClientHints.Browsers
        ]

        for client_hint <- client_hints do
          {local, _} = client_hint.source()

          [test_path, local]
          |> Path.join()
          |> File.exists?()
          |> assert
        end

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
          for {_type, local, _remote} <- database.sources() do
            [test_path, local]
            |> Path.join()
            |> File.exists?()
            |> assert
          end
        end

        maps = [
          UAInspector.ShortCodeMap.BrowserFamilies,
          UAInspector.ShortCodeMap.ClientBrowsers,
          UAInspector.ShortCodeMap.ClientHintBrowserMapping,
          UAInspector.ShortCodeMap.ClientHintOSMapping,
          UAInspector.ShortCodeMap.DesktopFamilies,
          UAInspector.ShortCodeMap.MobileBrowsers,
          UAInspector.ShortCodeMap.OSFamilies,
          UAInspector.ShortCodeMap.OSs
        ]

        for map <- maps do
          {local, _} = map.source()

          [test_path, local]
          |> Path.join()
          |> File.exists?()
          |> assert
        end
      end)

    assert String.contains?(console, test_path)

    File.rm_rf!(test_path)
  end
end
