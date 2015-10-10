defmodule Mix.Tasks.UAInspector.ShortCodeMaps.DownloadTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @tag :download
  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.Tasks.UAInspector.Download.ShortCodeMaps.run([])

      IO.write "n"
    end

    assert String.contains?(console, "Download aborted")
  end

  @tag :download
  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io [capture_prompt: true], fn ->
      Mix.Tasks.UAInspector.Download.ShortCodeMaps.run([])
    end

    assert String.contains?(console, "Really download? [Yn]")
  end

  @tag :download
  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.join(__DIR__, "../../downloads") |> Path.expand()

    console = capture_io fn ->
      Application.put_env(:ua_inspector, :database_path, test_path)
      Mix.Tasks.UAInspector.Download.ShortCodeMaps.run(["--force"])
      Application.put_env(:ua_inspector, :database_path, orig_path)

      maps = [
        UAInspector.ShortCodeMap.DeviceBrands,
        UAInspector.ShortCodeMap.OSs
      ]

      for map <- maps do
        [ test_path, map.local ]
        |> Path.join()
        |> File.exists?
        |> assert
      end
    end

    assert String.contains?(console, test_path)

    File.rm_rf! test_path
  end

  @tag :download
  test "missing configuration" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)

    console = capture_io :stderr, fn ->
      # capture regular output as well
      capture_io fn ->
        Application.put_env(:ua_inspector, :database_path, nil)
        Mix.Tasks.UAInspector.Download.ShortCodeMaps.run([])
        Application.put_env(:ua_inspector, :database_path, orig_path)
      end
    end

    assert String.contains?(console, "not configured")
  end
end
