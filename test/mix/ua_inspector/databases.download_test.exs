defmodule Mix.Tasks.UAInspector.Databases.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.Tasks.UAInspector.Databases.Download.run([])

      IO.write "n"
    end

    assert String.contains?(console, "Download aborted")
  end

  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io [capture_prompt: true], fn ->
      Mix.Tasks.UAInspector.Databases.Download.run([])
    end

    assert String.contains?(console, "Download parser databases? [Yn]")
  end

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.join(__DIR__, "../../downloads") |> Path.expand()

    console = capture_io fn ->
      Application.put_env(:ua_inspector, :database_path, test_path)
      Mix.Tasks.UAInspector.Databases.Download.run(["--force"])
      Application.put_env(:ua_inspector, :database_path, orig_path)

      databases = UAInspector.Database.Clients.sources ++
                  UAInspector.Database.Devices.sources ++
                  UAInspector.Database.OSs.sources

      for { local, _remote } <- databases do
        [ test_path, local ]
          |> Path.join()
          |> File.exists?
          |> assert
      end
    end

    assert String.contains?(console, test_path)

    File.rm_rf! test_path
  end

  test "missing configuration" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)

    console = capture_io :stderr, fn ->
      Application.put_env(:ua_inspector, :database_path, nil)
      Mix.Tasks.UAInspector.Databases.Download.run([])
      Application.put_env(:ua_inspector, :database_path, orig_path)
    end

    assert String.contains?(console, "not configured")
  end
end
