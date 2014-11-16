defmodule Mix.Tasks.ExAgent.Databases.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.Tasks.Ex_agent.Databases.Download.run(["--force"])

      databases = ExAgent.Database.Clients.sources ++
                  ExAgent.Database.Devices.sources ++
                  ExAgent.Database.Oss.sources

      for { local, _remote } <- databases do
        [ Mix.ExAgent.download_path, local ]
          |> Path.join()
          |> Path.expand()
          |> File.exists?
          |> assert
      end
    end

    assert String.contains?(console, Mix.ExAgent.download_path)
  end
end
