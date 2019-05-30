defmodule UAInspector.Deprecations.DownloaderDatabasePathPreparationTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias UAInspector.Downloader

  test "prepare_database_path/0" do
    assert capture_log(fn ->
             :ok = Application.put_env(:ua_inspector, :skip_download_readme, true)
             :ok = Downloader.prepare_database_path()
             :ok = Application.delete_env(:ua_inspector, :skip_download_readme)
           end) =~ ~r/declared internal/i
  end
end
