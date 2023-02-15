defmodule UAInspector.Downloader.ReleaseTest do
  use ExUnit.Case, async: false

  alias UAInspector.Downloader.Release

  @test_path Path.expand("../../downloads", __DIR__)
  @test_release Path.join(@test_path, "ua_inspector.release")

  setup_all do
    orig_path = Application.get_env(:ua_inspector, :database_path)
    remote_path = Application.get_env(:ua_inspector, :remote_path)
    skip_release = Application.get_env(:ua_inspector, :skip_download_release)

    :ok = Application.put_env(:ua_inspector, :database_path, @test_path)
    _ = File.rm_rf!(@test_path)

    on_exit(fn ->
      _ = File.rm_rf!(@test_path)
      :ok = Application.put_env(:ua_inspector, :database_path, orig_path)
      :ok = Application.put_env(:ua_inspector, :remote_path, remote_path)
      :ok = Application.put_env(:ua_inspector, :skip_download_release, skip_release)
    end)
  end

  test "release creation for default remote" do
    test_remote_path = [
      bot: "--ignore-value--",
      browser_engine: "--ignore-value--",
      client: "--ignore-value--",
      client_hints: "--ignore-value--",
      device: "--ignore-value--",
      os: "--ignore-value--",
      short_code_map: "--ignore-value--",
      vendor_fragment: "--ignore-value--"
    ]

    :ok = Application.put_env(:ua_inspector, :remote_path, test_remote_path)
    :ok = Release.write()

    refute File.exists?(@test_release)

    :ok = Application.delete_env(:ua_inspector, :remote_path)
    :ok = Application.put_env(:ua_inspector, :skip_download_release, true)
    :ok = Release.write()

    refute File.exists?(@test_release)

    :ok = Application.delete_env(:ua_inspector, :skip_download_release)
    :ok = Release.write()

    assert File.exists?(@test_release)
  end
end
