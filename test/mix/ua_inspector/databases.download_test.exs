defmodule Mix.Tasks.Ua_inspector.Databases.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.join(__DIR__, "../../downloads")

    console = capture_io fn ->
      Application.put_env(:ua_inspector, :database_path, test_path)
      Mix.Tasks.Ua_inspector.Databases.Download.run(["--force"])
      Application.put_env(:ua_inspector, :database_path, orig_path)

      databases = UAInspector.Database.Clients.sources ++
                  UAInspector.Database.Devices.sources ++
                  UAInspector.Database.Oss.sources

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
end
