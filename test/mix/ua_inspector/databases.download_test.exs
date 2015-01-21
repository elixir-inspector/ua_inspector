defmodule Mix.Tasks.Ua_inspector.Databases.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.Tasks.Ua_inspector.Databases.Download.run(["--force"])

      databases = UAInspector.Database.Clients.sources ++
                  UAInspector.Database.Devices.sources ++
                  UAInspector.Database.Oss.sources

      for { local, _remote } <- databases do
        [ Mix.UAInspector.download_path, local ]
          |> Path.join()
          |> Path.expand()
          |> File.exists?
          |> assert
      end
    end

    assert String.contains?(console, Mix.UAInspector.download_path)
  end
end
